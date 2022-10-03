//
//  Portainer.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//

import Combine
import Foundation
import os.log

public final class Portainer {

	// MARK: Static properties

	private static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "xyz.shameful.PortainerKit"

	public static let userDefaultsLoggingKey = "EnableDebugLogging"

	// MARK: Public properties

	/// Is `Portainer` setup?
	public private(set) var isSetup = false

	/// Endpoint URL
	public var url: URL?

	/// Used `URLSession`
	public var session: URLSession

	/// Authorization token
	public var token: String?

	// MARK: Private properties

	private let logger = Logger(subsystem: Portainer.bundleIdentifier, category: "PortainerKit")
	private let wsQueue = DispatchQueue(label: Portainer.bundleIdentifier.appending("WebSocket"), qos: .userInteractive)

	// MARK: init

	/// Initializes PortainerKit with endpoint URL and optional authorization token.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - token: Authorization JWT token
	@Sendable
	public init(url: URL? = nil, token: String? = nil) {
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = [
			"Accept-Encoding": "gzip, deflate"
		]

		let delegate = Portainer.URLSessionDelegate()
		self.session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

		self.url = url
		self.token = token
		if let url, let token {
			setup(url: url, token: token)
		}
	}

	// MARK: - Public functions

	@Sendable
	public func setup(url: URL, token: String) {
		self.url = url
		self.token = token
		self.isSetup = true
	}

	/// Fetches available endpoints.
	/// - Returns: `[Endpoint]`
	@Sendable
	public func fetchEndpoints() async throws -> [Endpoint] {
		let request = try request(for: .endpoints)
		return try await fetch(request: request)
	}

	/// Fetches available containers for supplied endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Parameter filters: Query filters
	/// - Returns: `[Container]`
	@Sendable
	public func fetchContainers(for endpointID: Int, filters: [String: [String]] = [:]) async throws -> [Container] {
		var queryItems = [
			URLQueryItem(name: "all", value: "true")
		]
		if !filters.isEmpty {
			let filtersEncoded = try JSONEncoder().encode(filters)
			guard let queryItemString = String(data: filtersEncoded, encoding: .utf8) else {
				throw APIError.encodingFailed
			}
			let queryItem = URLQueryItem(name: "filters", value: queryItemString)
			queryItems.append(queryItem)
		}
		let request = try request(for: .containers(endpointID: endpointID), query: queryItems)
		return try await fetch(request: request)
	}

	/// Inspects the requested container.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: `ContainerDetails`
	@Sendable
	public func inspectContainer(_ containerID: String, endpointID: Int) async throws -> ContainerDetails {
		let request = try request(for: .inspect(containerID: containerID, endpointID: endpointID))

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom { decoder -> Date in
			let dateFormatter = ISO8601DateFormatter()

			let container = try decoder.singleValueContainer()
			let str = try container.decode(String.self)

			dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
			if let date = dateFormatter.date(from: str) { return date }

			dateFormatter.formatOptions = [.withInternetDateTime]
			if let date = dateFormatter.date(from: str) { return date }

			throw DateError.invalidDate(dateString: str)
		}

		return try await fetch(request: request, decoder: decoder)
	}

	/// Executes selected action for container with supplied ID.
	/// - Parameters:
	///   - action: Executed action
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	@Sendable
	public func execute(_ action: ExecuteAction, containerID: String, endpointID: Int) async throws {
		var request = try request(for: .executeAction(containerID: containerID, endpointID: endpointID, action: action))
		request.httpMethod = "POST"
		request.httpBody = "{}".data(using: .utf8)

		let response = try await session.data(for: request)

		if let urlResponse = response.1 as? HTTPURLResponse {
			if !(200...304 ~= urlResponse.statusCode) {
				if let decoded = try? JSONDecoder().decode([String: String].self, from: response.0), let message = decoded[APIError.errorMessageKey] {
					throw APIError.fromMessage(message)
				} else {
					throw APIError.responseCodeUnacceptable(urlResponse.statusCode)
				}
			}
		} else {
			// It shouldn't happen, but we should gracefully handle it anyways.
			// For now, we're hoping it worked ¯\_(ツ)_/¯.
			assertionFailure("Response isn't HTTPURLResponse 🤨 [\(#fileID):\(#line)] \(response.1)")

			if let decoded = try? JSONDecoder().decode([String: String].self, from: response.0), let message = decoded[APIError.errorMessageKey] {
				throw APIError.fromMessage(message)
			}
		}
	}

	/// Fetches logs from container with supplied ID.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	///   - since: Fetch logs since then
	///   - tail: Number of lines, counting from the end
	///   - displayTimestamps: Display timestamps?
	/// - Returns: `String` logs
	@Sendable
	public func fetchLogs(containerID: String, endpointID: Int, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async throws -> String {
		let queryItems = [
			URLQueryItem(name: "since", value: "\(since)"),
			URLQueryItem(name: "stderr", value: "true"),
			URLQueryItem(name: "stdout", value: "true"),
			URLQueryItem(name: "tail", value: "\(tail)"),
			URLQueryItem(name: "timestamps", value: "\(displayTimestamps)")
		]
		let request = try request(for: .logs(containerID: containerID, endpointID: endpointID), query: queryItems)

		let (data, _) = try await session.data(for: request)
		guard let string = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else { throw APIError.decodingFailed }
		return string
	}

	/// Attaches to container with supplied ID.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: `WebSocketPassthroughSubject`
	@Sendable
	public func attach(to containerID: String, endpointID: Int) throws -> WebSocketPassthroughSubject {
		guard let url else {
			throw PortainerError.notSetup
		}

		guard let url: URL = {
			guard var components = URLComponents(url: url.appendingPathComponent(RequestPath.attach.path), resolvingAgainstBaseURL: true) else { return nil }
			components.scheme = url.scheme == "https" ? "wss" : "ws"
			components.queryItems = [
				URLQueryItem(name: "token", value: token),
				URLQueryItem(name: "endpointId", value: String(endpointID)),
				URLQueryItem(name: "id", value: containerID)
			]
			return components.url
		}() else { throw APIError.invalidURL }

		let task = session.webSocketTask(with: url)
		let passthroughSubject = WebSocketPassthroughSubject()

		@Sendable
		func setReceiveHandler() {
			wsQueue.async {
				task.receive { result in
					do {
						let message = WebSocketMessage(message: try result.get(), source: .server)
						passthroughSubject.send(message)
						setReceiveHandler()
					} catch {
						passthroughSubject.send(completion: .failure(error))
					}
				}
			}
		}

		setReceiveHandler()
		task.resume()

		return passthroughSubject
	}

	// MARK: - Private functions

	/// Creates a authorized URLRequest.
	/// - Parameter path: Request path
	/// - Parameter query: Optional URL query items
	/// - Returns: `URLRequest` with authorization header set.
	@Sendable
	private func request(for path: RequestPath, query: [URLQueryItem]? = nil) throws -> URLRequest {
		guard let url else {
			throw PortainerError.notSetup
		}

		var request: URLRequest
		if let query {
			guard var components = URLComponents(url: url.appendingPathComponent(path.path), resolvingAgainstBaseURL: true) else { throw APIError.invalidURL }
			components.queryItems = query
			guard let url = components.url else { throw APIError.invalidURL }
			request = URLRequest(url: url)
		} else {
			request = URLRequest(url: url.appendingPathComponent(path.path))
		}

		if let token {
			request.setValue(token, forHTTPHeaderField: "X-API-Key")
		}

		return request
	}

	/// Fetches & decodes data for supplied request.
	/// - Parameter request: `URLRequest`
	/// - Parameter decoder: `JSONDecoder`
	/// - Returns: `Output`
	@Sendable
	private func fetch<Output: Decodable>(request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> Output {
		let response = try await session.data(for: request)

//		if UserDefaults.standard.bool(forKey: Self.userDefaultsLoggingKey) {
//			logger.warning("Logging is enabled! All of the data for this request will be logged to the console. To disable it, set \(Self.userDefaultsLoggingKey) to false.")
//			let obj: [String: Any] = [
//				"data": response.0.base64EncodedString()
//			]
//			let json = try? JSONSerialization.data(withJSONObject: obj)
//			let str = json?.base64EncodedString() ?? "<none>"
//			logger.debug("\(request.url?.absoluteString ?? "<none>"): \(str)")
//		}

		do {
			let decoded = try decoder.decode(Output.self, from: response.0)
			return decoded
		} catch {
			if let errorJson = try? decoder.decode([String: String?].self, from: response.0), let message = errorJson[APIError.errorMessageKey] {
				throw APIError.fromMessage(message)
			} else {
				throw error
			}
		}
	}
}

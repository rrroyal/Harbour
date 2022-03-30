//
//  PortainerKit.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//

import Combine
import Foundation

@available(iOS 15, macOS 12, *)
public final class PortainerKit {
	public typealias WebSocketPassthroughSubject = PassthroughSubject<Result<WebSocketMessage, Error>, Error>
	
	// MARK: Public properties
	
	/// Endpoint URL
	public let url: URL
	
	/// Used `URLSession`
	public let session: URLSession
	
	// MARK: Public variables
	
	/// Authorization token
	public var token: String?
	
	// MARK: - init
	
	/// Initializes PortainerKit with endpoint URL and optional authorization token.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - token: Authorization JWT token
	public init(url: URL, token: String? = nil) {
		self.url = url
		
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip, deflate"]
		configuration.shouldUseExtendedBackgroundIdleMode = true
		configuration.networkServiceType = .responsiveData
		
		self.session = URLSession(configuration: configuration, delegate: PortainerKit.URLSessionDelegate(), delegateQueue: nil)
		self.token = token
	}
	
	// MARK: - Public functions
	
	/// Logs in to Portainer.
	/// - Parameters:
	///   - username: Username
	///   - password: Password
	/// - Returns: JWT token
	public func login(username: String, password: String) async throws -> String {
		var request = try request(for: .login)
		request.httpMethod = "POST"
		
		let body = [
			"Username": username,
			"Password": password
		]
		request.httpBody = try JSONEncoder().encode(body)
		
		let (data, _) = try await session.data(for: request)
		let decoded = try JSONDecoder().decode([String: String].self, from: data)
		
		if let jwt: String = decoded["jwt"] {
			token = jwt
			return jwt
		} else {
			throw APIError.fromMessage(decoded[APIError.errorMessageKey])
		}
	}
	
	/// Fetches available endpoints.
	/// - Returns: `[Endpoint]`
	public func fetchEndpoints() async throws -> [Endpoint] {
		let request = try request(for: .endpoints)
		return try await fetch(request: request)
	}
	
	/// Fetches available containers for supplied endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Parameter filters: Query filters
	/// - Returns: `[Container]`
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
	public func inspectContainer(_ containerID: String, endpointID: Int) async throws -> ContainerDetails {
		let request = try request(for: .containerDetails(containerID: containerID, endpointID: endpointID))
		
		let decoder = JSONDecoder()
		let dateFormatter = ISO8601DateFormatter()
		
		decoder.dateDecodingStrategy = .custom { decoder -> Date in
			let container = try decoder.singleValueContainer()
			let str = try container.decode(String.self)
			
			// ISO8601 with fractional seconds
			dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
			if let date = dateFormatter.date(from: str) { return date }
			
			// ISO8601 without fractional seconds
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
	public func attach(to containerID: String, endpointID: Int) throws -> WebSocketPassthroughSubject {
		guard let url: URL = {
			guard var components: URLComponents = URLComponents(url: self.url.appendingPathComponent(RequestPath.attach.path), resolvingAgainstBaseURL: true) else { return nil }
			components.scheme = self.url.scheme == "https" ? "wss" : "ws"
			components.queryItems = [
				URLQueryItem(name: "token", value: token),
				URLQueryItem(name: "endpointId", value: String(endpointID)),
				URLQueryItem(name: "id", value: containerID)
			]
			return components.url
		}() else { throw APIError.invalidURL }
		
		let task = session.webSocketTask(with: url)
		let passthroughSubject = WebSocketPassthroughSubject()
		
		func setReceiveHandler() {
			DispatchQueue.main.async { [weak self] in
				guard self != nil else { return }
				
				task.receive { result in
					do {
						let message = WebSocketMessage(message: try result.get(), source: .server)
						passthroughSubject.send(.success(message))
						setReceiveHandler()
					} catch {
						passthroughSubject.send(.failure(error))
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
	private func request(for path: RequestPath, query: [URLQueryItem]? = nil) throws -> URLRequest {
		var request: URLRequest
		if let query = query {
			guard var components: URLComponents = URLComponents(url: url.appendingPathComponent(path.path), resolvingAgainstBaseURL: true) else { throw APIError.invalidURL }
			components.queryItems = query
			guard let url = components.url else { throw APIError.invalidURL }
			request = URLRequest(url: url)
		} else {
			request = URLRequest(url: url.appendingPathComponent(path.path))
		}
				
		if let token = token {
			request.setValue(token, forHTTPHeaderField: "X-API-Key")
		}

		return request
	}
	
	/// Fetches & decodes data for supplied request.
	/// - Parameter request: URLRequest
	/// - Parameter decoder: JSONDecoder
	/// - Returns: Output
	private func fetch<Output: Decodable>(request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> Output {
		let response = try await session.data(for: request)
		
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

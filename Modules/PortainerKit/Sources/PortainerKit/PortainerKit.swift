//
//  PortainerKit.swift
//  PortainerKit
//
//  Created by unitears on 10/06/2021.
//

import Combine
import Foundation

@available(iOS 15, macOS 12, *)
public class PortainerKit {
	public typealias WebSocketPassthroughSubject = PassthroughSubject<Result<WebSocketMessage, Error>, Error>
	
	// MARK: Public properties
	
	/// Endpoint URL
	public let url: URL
	
	// MARK: Private properties
	
	/// Module-private `URLSession`
	private let session: URLSession
	
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
		configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip"]
		configuration.shouldUseExtendedBackgroundIdleMode = true
		configuration.networkServiceType = .responsiveData
		
		self.session = URLSession(configuration: configuration)
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
		request.httpBody = try JSONSerialization.data(withJSONObject: body)
		
		let (data, _) = try await session.data(for: request)
		let decoded = try JSONDecoder().decode([String: String].self, from: data)
		
		if let jwt: String = decoded["jwt"] {
			token = jwt
			return jwt
		} else {
			throw APIError.fromMessage(decoded["message"])
		}
	}
	
	/// Fetches available endpoints.
	/// - Returns: `[Endpoint]`
	public func getEndpoints() async throws -> [Endpoint] {
		let request = try request(for: .endpoints)
		return try await fetch(request: request)
	}
	
	/// Fetches available containers for supplied endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: `[Container]`
	public func getContainers(for endpointID: Int) async throws -> [Container] {
		let request = try request(for: .containers(endpointID: endpointID))
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
		
		/// Dear Docker/Portainer developers -
		/// WHY THE HELL DO YOU RETURN FRACTIONAL SECONDS ONLY SOMETIMES
		/// Sincerely, deeply upset me.
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
		var request = try request(for: .executeAction(action, containerID: containerID, endpointID: endpointID))
		request.httpMethod = "POST"
		
		let response = try await session.data(for: request)
		if let statusCode = (response.1 as? HTTPURLResponse)?.statusCode {
			if !(200...304 ~= statusCode) {
				throw APIError.responseCodeUnacceptable(statusCode)
			}
		} else {
			// It shouldn't happen, but we should gracefully handle it anyways.
			// For now, we're hoping it worked ¯\_(ツ)_/¯.
			assertionFailure("Response isn't HTTPURLResponse 🤨 [\(#fileID):\(#line)]")
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
	public func getLogs(containerID: String, endpointID: Int, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false) async throws -> String {
		let request = try request(for: .logs(containerID: containerID, endpointID: endpointID, since: since, tail: tail, timestamps: displayTimestamps))
		
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
		let url: URL? = {
			guard var components: URLComponents = URLComponents(url: self.url.appendingPathComponent(RequestPath.attach.path), resolvingAgainstBaseURL: true) else { return nil }
			components.scheme = components.scheme?.replacingOccurrences(of: "http", with: "ws") ?? "ws"
			components.queryItems = [
				URLQueryItem(name: "token", value: token),
				URLQueryItem(name: "endpointId", value: String(endpointID)),
				URLQueryItem(name: "id", value: containerID)
			]
			return components.url
		}()
						
		guard let url = url else { throw APIError.invalidURL }
		let task = session.webSocketTask(with: url)
		let passthroughSubject = WebSocketPassthroughSubject()
		
		func setReceiveHandler() {
			DispatchQueue.main.async { [weak self] in
				guard self != nil else { return }
				task.receive {
					do {
						let message = WebSocketMessage(message: try $0.get(), source: .server)
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
	/// - Returns: `URLRequest` with authorization header set.
	private func request(for path: RequestPath, overrideURL: URL? = nil) throws -> URLRequest {
		guard let url = URL(string: (overrideURL ?? url).absoluteString + path.path) else { throw APIError.invalidURL }
		var request = URLRequest(url: url)
		
		if let token = token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		
		return request
	}
	
	/// Fetches & decodes data for supplied request.
	/// - Parameter request: Request
	/// - Parameter decoder: JSONDecoder
	/// - Returns: Output
	private func fetch<Output: Codable>(request: URLRequest, decoder: JSONDecoder = JSONDecoder()) async throws -> Output {
		let response = try await session.data(for: request)
		
		do {
			let decoded = try decoder.decode(Output.self, from: response.0)
			return decoded
		} catch {
			if let errorJson = try? decoder.decode([String: String].self, from: response.0),
			   let message = errorJson["message"] {
				throw APIError.fromMessage(message)
			} else {
				throw error
			}
		}
	}
}

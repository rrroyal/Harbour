//
//  PortainerKit.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
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
	private var token: String?
	
	// MARK: - init
	
	/// Initializes PortainerKit with endpoint URL and optional authorization token.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - token: Authorization JWT token
	public init(url: URL, token: String? = nil) {
		self.url = url
		
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip"]
		
		self.session = URLSession(configuration: configuration)
		self.token = token
	}
	
	// MARK: - Public functions
	
	/// Logs in to Portainer.
	/// - Parameters:
	///   - username: Username
	///   - password: Password
	/// - Returns: Result containing JWT token or error.
	public func login(username: String, password: String) async -> Result<String, Error> {
		guard var request = request(for: .login) else { return .failure(APIError.invalidURL) }
		request.httpMethod = "POST"
		
		do {
			let body = [
				"Username": username,
				"Password": password
			]
			request.httpBody = try JSONSerialization.data(withJSONObject: body)
		} catch {
			return .failure(error)
		}
		
		do {
			let (data, _) = try await session.data(for: request)
			let decoded = try JSONDecoder().decode([String: String].self, from: data)
			
			if let jwt: String = decoded["jwt"] {
				self.token = jwt
				return .success(jwt)
			} else {
				return .failure(APIError.fromMessage(decoded["message"]))
			}
		} catch {
			return .failure(error)
		}
	}
	
	/// Fetches available endpoints.
	/// - Returns: Result containing `[Endpoint]` or error.
	public func getEndpoints() async -> Result<[Endpoint], Error> {
		guard let request = request(for: .endpoints) else { return .failure(APIError.invalidURL) }
		do {
			let response = try await session.data(for: request)
			let parsed: Result<[Endpoint], Error> = parseResponse(response)
			return parsed
		} catch {
			return .failure(error)
		}
	}
	
	/// Fetches available containers for supplied endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: Result containing `[Container]` or error.
	public func getContainers(for endpointID: Int) async -> Result<[Container], Error> {
		guard let request = request(for: .containers(endpointID: endpointID)) else { return .failure(APIError.invalidURL) }
		do {
			let response = try await session.data(for: request)
			let parsed: Result<[Container], Error> = parseResponse(response)
			return parsed
		} catch {
			return .failure(error)
		}
	}
	
	/// Inspects the requested container.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: Result containing `ContainerDetails` or error.
	public func inspectContainer(_ containerID: String, endpointID: Int) async -> Result<ContainerDetails, Error> {
		guard let request = request(for: .containerDetails(containerID: containerID, endpointID: endpointID)) else { return .failure(APIError.invalidURL) }
		do {
			let response = try await session.data(for: request)
			
			let decoder = JSONDecoder()
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
			decoder.dateDecodingStrategy = .formatted(dateFormatter)

			let parsed: Result<ContainerDetails, Error> = parseResponse(response, decoder: decoder)
			return parsed
		} catch {
			return .failure(error)
		}
	}
	
	/// Executes selected action for container with supplied ID.
	/// - Parameters:
	///   - action: Executed action
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: Result containing void success or error.
	public func execute(_ action: ExecuteAction, containerID: String, endpointID: Int) async -> Result<Void, Error> {
		guard var request = request(for: .executeAction(action, containerID: containerID, endpointID: endpointID)) else { return .failure(APIError.invalidURL) }
		request.httpMethod = "POST"
		
		do {
			let response = try await session.data(for: request)
			if let statusCode = (response.1 as? HTTPURLResponse)?.statusCode {
				if 200 ... 304 ~= statusCode {
					return .success(())
				} else {
					return .failure(APIError.responseCodeUnacceptable(statusCode))
				}
			} else {
				// It shouldn't happen, but we should gracefully handle it anyways.
				// For now, we're hoping it worked ¯\_(ツ)_/¯.
				print("Response isn't HTTPURLResponse!", #fileID, #line)
				return .success(())
			}
		} catch {
			return .failure(error)
		}
	}
	
	/// Attaches to container with supplied ID.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: Result containing `WebSocketPassthroughSubject` or error.
	public func attach(to containerID: String, endpointID: Int) -> Result<WebSocketPassthroughSubject, Error> {
		let url: URL? = {
			guard var components: URLComponents = URLComponents(url: self.url.appendingPathComponent(RequestPath.attach.path), resolvingAgainstBaseURL: true) else { return nil }
			components.scheme = components.scheme?.replacingOccurrences(of: "http", with: "ws") ?? "ws"
			components.queryItems = [
				URLQueryItem(name: "token", value: self.token),
				URLQueryItem(name: "endpointId", value: String(endpointID)),
				URLQueryItem(name: "id", value: containerID)
			]
			return components.url
		}()
						
		guard let url = url else { return .failure(APIError.invalidURL) }
		
		let task = session.webSocketTask(with: url)
		
		let passthroughSubject = WebSocketPassthroughSubject()
		
		_ = passthroughSubject
			.tryFilter { try ($0.get()).source == .client }
			.sink(receiveCompletion: { _ in
				task.cancel()
			}, receiveValue: { value in
				do {
					let message = try value.get()
					task.send(message.message) { error in
						if let error = error { passthroughSubject.send(.failure(error)) }
					}
				} catch {
					passthroughSubject.send(.failure(error))
				}
			})
		
		func setReceiveHandler() {
			DispatchQueue.main.async { [weak self] in
				guard self != nil else { return }
				
				task.receive {
					defer { setReceiveHandler() }
					do {
						let message = WebSocketMessage(message: try $0.get(), source: .server)
						passthroughSubject.send(.success(message))
					} catch {
						passthroughSubject.send(.failure(error))
					}
				}
			}
		}
		
		setReceiveHandler()
		task.resume()
		
		return .success(passthroughSubject)
	}
	
	// MARK: - Private functions
	
	/// Creates a authorized URLRequest.
	/// - Parameter path: Request path
	/// - Returns: `URLRequest` with authorization header set.
	private func request(for path: RequestPath, overrideURL: URL? = nil) -> URLRequest? {
		guard let url = URL(string: (overrideURL ?? self.url).absoluteString + path.path) else { return nil }
		var request = URLRequest(url: url)
		
		if let token = self.token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}
		
		return request
	}
	
	/// Parses the request response, decoding data and/or handling errors.
	/// - Parameter response: Request response
	/// - Returns: Decoded output or error.
	private func parseResponse<Output: Codable>(_ response: (Data, URLResponse), decoder: JSONDecoder = JSONDecoder()) -> Result<Output, Error> {
		do {
			let decoded = try decoder.decode(Output.self, from: response.0)
			return .success(decoded)
		} catch {
			// swiftlint:disable indentation_width
			if let errorJson = try? decoder.decode([String: String].self, from: response.0),
			   let message = errorJson["message"] {
				return .failure(APIError.fromMessage(message))
			} else {
				return .failure(error)
			}
		}
	}
}

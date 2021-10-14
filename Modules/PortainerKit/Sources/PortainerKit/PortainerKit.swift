//
//  PortainerKit.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//

import Combine
import Foundation

@available(iOS 14, macOS 11, *)
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
		configuration.timeoutIntervalForRequest = 30
		configuration.timeoutIntervalForResource = 60
		
		self.session = URLSession(configuration: configuration)
		self.token = token
	}
	
	// MARK: - Public functions
	
	/// Logs in to Portainer.
	/// - Parameters:
	///   - username: Username
	///   - password: Password
	/// - Returns: JWT token
	public func login(username: String, password: String, completionHandler: @escaping (Result<String, Error>) -> ()) {
		do {
			var request = try request(for: .login)
			request.httpMethod = "POST"
			
			let body = [
				"Username": username,
				"Password": password
			]
			request.httpBody = try JSONSerialization.data(withJSONObject: body)
						
			session.dataTask(with: request) { data, response, error in
				print(data?.base64EncodedString() ?? "<empty>", response ?? "<empty>", error.debugDescription)

				if let error = error {
					completionHandler(.failure(error))
					return
				}
				
				do {
					guard let data = data else {
						throw APIError.noData
					}
					
					let decoded = try JSONDecoder().decode([String: String].self, from: data)
					
					if let jwt: String = decoded["jwt"] {
						self.token = jwt
						completionHandler(.success(jwt))
					} else {
						throw APIError.fromMessage(decoded["message"])
					}
				} catch {
					completionHandler(.failure(error))
				}
			}
			.resume()
		} catch {
			completionHandler(.failure(error))
		}
	}
	
	/// Fetches available endpoints.
	/// - Returns: `[Endpoint]`
	public func getEndpoints(completionHandler: @escaping (Result<[Endpoint], Error>) -> ()) {
		do {
			let request = try request(for: .endpoints)
			fetch(request: request, completionHandler: completionHandler)
		} catch {
			completionHandler(.failure(error))
		}
	}
	
	/// Fetches available containers for supplied endpoint ID.
	/// - Parameter endpointID: Endpoint ID
	/// - Returns: `[Container]`
	public func getContainers(for endpointID: Int, completionHandler: @escaping (Result<[Container], Error>) -> ()) {
		do {
			let request = try request(for: .containers(endpointID: endpointID))
			fetch(request: request, completionHandler: completionHandler)
		} catch {
			completionHandler(.failure(error))
		}
	}
	
	/// Inspects the requested container.
	/// - Parameters:
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	/// - Returns: `ContainerDetails`
	public func inspectContainer(_ containerID: String, endpointID: Int, completionHandler: @escaping (Result<ContainerDetails, Error>) -> ()) {
		do {
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
			
			fetch(request: request, decoder: decoder, completionHandler: completionHandler)
		} catch {
			completionHandler(.failure(error))
		}
	}
	
	/// Executes selected action for container with supplied ID.
	/// - Parameters:
	///   - action: Executed action
	///   - containerID: Container ID
	///   - endpointID: Endpoint ID
	public func execute(_ action: ExecuteAction, containerID: String, endpointID: Int, completionHandler: @escaping (Result<Void, Error>) -> ()) {
		do {
			var request = try request(for: .executeAction(action, containerID: containerID, endpointID: endpointID))
			request.httpMethod = "POST"
			
			session.dataTask(with: request) { data, response, error in
				print(data?.base64EncodedString() ?? "<empty>", response ?? "<empty>", error.debugDescription)

				if let error = error {
					completionHandler(.failure(error))
					return
				}
				
				if let statusCode = (response as? HTTPURLResponse)?.statusCode {
					if !(200...304 ~= statusCode) {
						completionHandler(.failure(APIError.responseCodeUnacceptable(statusCode)))
					} else {
						completionHandler(.success(()))
					}
				} else {
					// It shouldn't happen, but we should gracefully handle it anyways.
					// For now, we're hoping it worked ¯\_(ツ)_/¯.
					assertionFailure("Response isn't HTTPURLResponse 🤨 [\(#fileID):\(#line)]")
				}
			}
			.resume()
		} catch {
			completionHandler(.failure(error))
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
	public func getLogs(containerID: String, endpointID: Int, since: TimeInterval = 0, tail: Int = 100, displayTimestamps: Bool = false, completionHandler: @escaping (Result<String, Error>) -> ()) {
		do {
			let request = try request(for: .logs(containerID: containerID, endpointID: endpointID, since: since, tail: tail, timestamps: displayTimestamps))
			
			session.dataTask(with: request) { data, response, error in
				print(data?.base64EncodedString() ?? "<empty>", response ?? "<empty>", error.debugDescription)

				guard let data = data else {
					completionHandler(.failure(APIError.noData))
					return
				}
								
				guard let string = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
					completionHandler(.failure(APIError.decodingFailed))
					return
				}
				
				completionHandler(.success(string))
			}
			.resume()
		} catch {
			completionHandler(.failure(error))
		}
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
	private func fetch<Output: Codable>(request: URLRequest, decoder: JSONDecoder = JSONDecoder(), completionHandler: @escaping (Result<Output, Error>) -> ()) {
		session.dataTask(with: request) { data, response, error in
			print(data?.base64EncodedString() ?? "<empty>", response ?? "<empty>", error.debugDescription)

			if let error = error {
				completionHandler(.failure(error))
				return
			}
			
			guard let data = data else {
				completionHandler(.failure(APIError.noData))
				return
			}
			
			do {
				let decoded = try decoder.decode(Output.self, from: data)
				completionHandler(.success(decoded))
			} catch {
				if let errorJson = try? decoder.decode([String: String].self, from: data),
				   let message = errorJson["message"] {
					completionHandler(.failure(APIError.fromMessage(message)))
				} else {
					completionHandler(.failure(error))
				}
			}
		}
		.resume()
	}
}

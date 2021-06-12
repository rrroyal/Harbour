//
//  PortainerKit.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//

import Foundation

@available(iOS 15, macOS 12, *)
public class PortainerKit {
	
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
	/// - Returns: Result containing JWT token and error.
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
	/// - Returns: Result containing `[Endpoint]` and error.
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
	/// - Returns: Result containing `[Container]` and error.
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
	/// - Returns: Result containing `ContainerDetails` and error.
	public func inspectContainer(_ containerID: String, endpointID: Int) async -> Result<ContainerDetails, Error> {
		guard let request = request(for: .containerDetails(endpointID: endpointID, containerID: containerID)) else { return .failure(APIError.invalidURL) }
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
	/// - Returns: Result containing void success and error.
	public func execute(_ action: ExecuteAction, containerID: String, endpointID: Int) async -> Result<Void, Error> {
		guard var request = request(for: .executeAction(action, endpointID: endpointID, containerID: containerID)) else { return .failure(APIError.invalidURL) }
		request.httpMethod = "POST"
		
		do {
			let response = try await session.data(for: request)
			guard let res = response.1 as? HTTPURLResponse else {
				// It shouldn't happen, but we should gracefully handle it anyways.
				// For now, we're hoping it worked ¯\_(ツ)_/¯.
				print("Response isn't HTTPURLResponse!", #fileID, #line)
				return .success(())
			}
			
			if 200...304 ~= res.statusCode {
				return .success(())
			} else {
				return .failure(APIError.responseCodeOutsideRange(res.statusCode))
			}
		} catch {
			return .failure(error)
		}
	}
	
	// MARK: - Private functions
	
	/// Creates a authorized URLRequest.
	/// - Parameter path: Request path
	/// - Returns: `URLRequest` with authorization header set.
	private func request(for path: RequestPath) -> URLRequest? {
		guard let url = URL(string: "\(self.url)/\(path.path)") else { return nil }
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
			if let errorJson = try? decoder.decode([String: String].self, from: response.0),
			   let message = errorJson["message"] {
				return .failure(APIError.fromMessage(message))
			} else {
				return .failure(error)
			}
		}
	}
}

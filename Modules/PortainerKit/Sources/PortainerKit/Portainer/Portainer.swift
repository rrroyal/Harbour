//
//  Portainer.swift
//  PortainerKit
//
//  Created by royal on 10/06/2021.
//  Copyright © 2023 shameful. All rights reserved.
//

import Combine
import Foundation
import OSLog

public final class Portainer {

	// MARK: Static properties

	private static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "xyz.shameful.PortainerKit"

	//	public static let userDefaultsLoggingKey = "PKEnableDebugLogging"

	// MARK: Public properties

	/// Is `Portainer` setup?
	public private(set) var isSetup = false

	/// Server URL
	public var serverURL: URL?

	/// Underlying `URLSession`
	public private(set) var session: URLSession

	/// Authorization token
	public var token: String?

	// MARK: Internal properties

	internal let logger = Logger(subsystem: Portainer.bundleIdentifier, category: "PortainerKit")
	internal let wsQueue = DispatchQueue(label: Portainer.bundleIdentifier.appending(".WebSocket"), qos: .utility)

	internal let jsonDecoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom { decoder -> Date in
			let dateFormatter = ISO8601DateFormatter()

			let container = try decoder.singleValueContainer()
			do {
				let str = try container.decode(String.self)

				dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
				if let date = dateFormatter.date(from: str) { return date }

				dateFormatter.formatOptions = [.withInternetDateTime]
				if let date = dateFormatter.date(from: str) { return date }

				throw DateError.invalidDate(dateString: str)
			} catch {
				if let decodingError = error as? DecodingError {
					let number = try container.decode(TimeInterval.self)
					return Date(timeIntervalSince1970: number)
				}

				throw error
			}
		}
		return decoder
	}()

	// MARK: init

	/// Initializes PortainerKit with endpoint URL and optional authorization token.
	/// - Parameters:
	///   - url: Endpoint URL
	///   - token: Authorization JWT token
	///   - urlSessionConfiguration: Configuration of underlying URLSession
	@Sendable
	public init(serverURL: URL? = nil, token: String? = nil, urlSessionConfiguration: URLSessionConfiguration = .default) {
		urlSessionConfiguration.httpAdditionalHeaders = [
			"Accept-Encoding": "gzip, deflate"
		]

		let delegate = Portainer.URLSessionDelegate()
		self.session = URLSession(configuration: urlSessionConfiguration, delegate: delegate, delegateQueue: nil)

		self.serverURL = serverURL
		self.token = token
		if let serverURL, let token {
			setup(url: serverURL, token: token)
		}
	}
}

// MARK: - Portainer+Utility

internal extension Portainer {
	/// Creates an authorized URLRequest.
	/// - Parameter path: Request path
	/// - Parameter query: Optional URL query items
	/// - Returns: `URLRequest` with authorization header set.
	@Sendable
	func request(for path: RequestPath, query: [URLQueryItem]? = nil) throws -> URLRequest {
		guard let serverURL else {
			throw PortainerError.notSetup
		}

		var request: URLRequest
		if let query {
			guard var components = URLComponents(url: serverURL.appendingPathComponent(path.path), resolvingAgainstBaseURL: true) else { throw PortainerError.invalidURL }
			components.queryItems = query
			guard let url = components.url else { throw PortainerError.invalidURL }
			request = URLRequest(url: url)
		} else {
			request = URLRequest(url: serverURL.appendingPathComponent(path.path))
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
	func fetch<Output: Decodable>(request: URLRequest) async throws -> Output {
		let (data, response) = try await session.data(for: request)

		//		if UserDefaults.standard.bool(forKey: Self.userDefaultsLoggingKey) {
		//			logger.warning("Logging is enabled! All of the data for this request will be logged to the console. To disable it, set \(Self.userDefaultsLoggingKey) to false.")
		//			let obj: [String: Any] = [
		//				"data": response.0.base64EncodedString()
		//			]
		//			let json = try? JSONSerialization.data(withJSONObject: obj)
		//			let str = json?.base64EncodedString() ?? "<none>"
		//			logger.debug("\(request.url?.absoluteString ?? "<none>"): \(str)")
		//		}

		return try decode(from: data, response: response)
	}

	/// Decodes `data` to provided `Output`, or throws an error if failed.
	/// - Parameters:
	///   - data: `Data` to be decoded
	///   - response: `URLResponse` from the request
	/// - Returns: `Output`
	@Sendable
	func decode<Output: Decodable>(from data: Data, response: URLResponse) throws -> Output {
		do {
			let decoded = try jsonDecoder.decode(Output.self, from: data)
			return decoded
		} catch {
			if let error = getError(from: data, response: response) {
				throw error
			} else {
				throw PortainerError.unknownError
			}
		}
	}
	
	/// Gets the error from the provided data and response.
	/// - Parameters:
	///   - data: Response data
	///   - response: `URLResponse`
	/// - Returns: `Error` if needed
	@Sendable
	func getError(from data: Data, response: URLResponse) -> Error? {
		// Decode error message first...
		if let decoded = try? jsonDecoder.decode(APIError.self, from: data) {
		   return decoded
		}

		// ...if not, get the response status code...
		if let urlResponse = response as? HTTPURLResponse {
			// ...return response code
			if !(200...304 ~= urlResponse.statusCode) {
				return PortainerError.responseCodeUnacceptable(urlResponse.statusCode)
			}
		} else {
			// ...or call assertionFailure and throw a `APIError.unknownError`.
			assertionFailure("Response isn't HTTPURLResponse 🤨 [\(#fileID):\(#line)]\n\(response)")

			return PortainerError.unknownError
		}

		return nil
	}
}

// MARK: - Portainer+State

public extension Portainer {
	/// Sets up `Portainer` with specfied URL and authorization token.
	/// - Parameters:
	///   - url: Server URL
	///   - token: Authorization token
	@Sendable
	func setup(url: URL, token: String) {
		self.serverURL = url
		self.token = token
		self.isSetup = true
	}

	/// Resets the `Portainer` state.
	@Sendable
	func reset() {
		self.serverURL = nil
		self.token = nil
		self.isSetup = false
	}
}

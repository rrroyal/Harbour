//
//  Keychain.swift
//  Keychain
//
//  Created by royal on 10/06/2021.
//

import Foundation
import Security

public final class Keychain {
	private typealias QueryDictionary = Dictionary<CFString, Any>
	
	let service: String
	let accessGroup: String?
	let synchronizable: Bool = true
	
	private let baseQuery: QueryDictionary
	
	private let textEncoding: String.Encoding = .utf8
	
	// MARK: - init
	
	/// Initializes Keychain with supplied configuration
	/// - Parameters:
	///   - service: Service (i.e. app bundleID)
	///   - accessGroup: Access group (i.e. app group)
	public init(service: String, accessGroup: String) {
		self.service = service
		self.accessGroup = accessGroup
		
		self.baseQuery = [
			kSecAttrAccessGroup: accessGroup,
			kSecAttrSynchronizable: synchronizable
		]
	}
	
	// MARK: - Public functions
	
	/// Saves the token to keychain
	/// - Parameters:
	///   - server: Service URL
	///   - username: Account username
	///   - token: Account token
	///   - comment: Item comment
	///   - hasPassword: Also has password?
	public func saveToken(server: URL, username: String, token: String, comment: String? = nil, hasPassword: Bool) throws {
		var query = tokenQuery(for: server)
		query[kSecAttrAccount] = username
		query[kSecAttrIsNegative] = hasPassword
		
		guard let data = token.data(using: self.textEncoding) else {
			throw KeychainError.encodingFailed
		}
		let attributes: QueryDictionary = [
			kSecValueData: data,
			kSecAttrComment: comment as Any,
			kSecAttrLabel: server.absoluteString
		]
		try addOrUpdate(query: query, attributes: attributes)
	}
	
	/// Saves credentials to keychain
	/// - Parameters:
	///   - server: Service URL
	///   - username: Account username
	///   - password: Account password
	///   - comment: Item comment
	public func saveCredentials(server: URL, username: String, password: String, comment: String? = nil) throws {
		var query = credentialsQuery(for: server)
		query[kSecAttrAccount] = username
		
		guard let data = password.data(using: self.textEncoding) else {
			throw KeychainError.encodingFailed
		}
		let attributes: QueryDictionary = [
			kSecValueData: data,
			kSecAttrComment: comment as Any,
		]
		try addOrUpdate(query: query, attributes: attributes)
	}
	
	/// Retrieves token
	/// - Parameter server: Service URL
	/// - Returns: Token
	public func getToken(server: URL) throws -> String {
		var query = tokenQuery(for: server)
		query[kSecReturnData] = true
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status == errSecSuccess else {
			throw SecError(status)
		}
		
		guard let data = item as? Data,
			  let password = String(data: data, encoding: self.textEncoding) else {
				  throw KeychainError.decodingFailed
			  }
		
		return password
	}
	
	/// Retrieves credentials
	/// - Parameter server: Service URL
	/// - Returns: Username and password
	public func getCredentials(server: URL) throws -> (username: String, password: String) {
		var query = credentialsQuery(for: server)
		query[kSecReturnData] = true
		query[kSecReturnAttributes] = true
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status == errSecSuccess else {
			throw SecError(status)
		}
		
		guard let dictionary = item as? [String: Any],
			  let username = dictionary[kSecAttrAccount as String] as? String,
			  let passwordData = dictionary[kSecValueData as String] as? Data,
			  let passwordString = String(data: passwordData, encoding: self.textEncoding) else {
				  throw KeychainError.decodingFailed
			  }
		
		return (username, passwordString)
	}
	
	/// Deletes token  for supplied URL
	/// - Parameter server: Service URL
	public func removeToken(server: URL) throws {
		let query = tokenQuery(for: server)
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else { throw SecError(status) }
	}
	
	/// Deletes credentials  for supplied URL
	/// - Parameter server: Service URL
	public func removeCredentials(server: URL) throws {
		let query = credentialsQuery(for: server)
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else { throw SecError(status) }
	}
	
	/// Returns all stored URLs
	/// - Returns: Array of URLs
	public func getURLs() throws -> [URL] {
		let query: QueryDictionary = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrDescription: Self.tokenItemDescription,
			kSecMatchLimit: kSecMatchLimitAll,
			kSecReturnAttributes: true,
			kSecReturnData: false
		]
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(self.baseQuery.merging(query, uniquingKeysWith: { $1 }) as CFDictionary, &item)
		guard status == errSecSuccess else {
			throw SecError(status)
		}
		
		guard let dict = item as? [[String: Any]] else {
			throw KeychainError.decodingFailed
		}
		
		let urls = dict.compactMap { $0[kSecAttrLabel as String] as? String }.compactMap { URL(string: $0) }
		return urls
	}
	
	// MARK: - Helpers
	
	internal static let tokenItemDescription = "Harbour - Token"
		
	/// Creates token query for supplied URL
	/// - Parameter server: Service URL
	/// - Returns: SecItem dictionary
	private func tokenQuery(for server: URL) -> QueryDictionary {
		let query: QueryDictionary = [
			kSecClass: kSecClassGenericPassword,
			kSecAttrDescription: Self.tokenItemDescription,
			kSecAttrService: server.absoluteString
		]
		return self.baseQuery.merging(query, uniquingKeysWith: { $1 })
	}
	
	internal static let credentialsItemDescription = "Harbour - Credentials"
	
	/// Creates credentials query for supplied URL
	/// - Parameter server: Service URL
	/// - Returns: SecItem dictionary
	private func credentialsQuery(for server: URL) -> QueryDictionary {
		var query: QueryDictionary = [
			kSecClass: kSecClassInternetPassword,
			kSecAttrAuthenticationType: kSecAttrAuthenticationTypeHTMLForm,
			kSecAttrDescription: Self.credentialsItemDescription,
			kSecAttrLabel: server.absoluteString,
			kSecAttrPath: server.path
			// kSecAttrService: server.absoluteString,
		]
		if let host = server.host { query[kSecAttrServer] = host }
		if let port = server.port { query[kSecAttrPort] = port }
		return self.baseQuery.merging(query, uniquingKeysWith: { $1 })
	}
	
	/// Adds or updates item with supplied query and attributes,
	/// - Parameters:
	///   - query: Item query
	///   - attributes: Item attributes
	private func addOrUpdate(query: QueryDictionary, attributes: QueryDictionary) throws {
		let addQuery = query.merging(attributes, uniquingKeysWith: { $1 })
		let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
				
		if addStatus == errSecDuplicateItem {
			let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
			guard updateStatus == errSecSuccess else {
				throw SecError(updateStatus)
			}
		} else {
			guard addStatus == errSecSuccess else {
				throw SecError(addStatus)
			}
		}
	}
}

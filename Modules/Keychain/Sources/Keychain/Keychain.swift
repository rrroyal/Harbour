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
	///   - token: Account token
	///   - comment: Item comment
	public func saveToken(server: URL, token: String, comment: String? = nil) throws {
		let query = tokenQuery(for: server)
//		query[kSecAttrAccount] = server.absoluteString

		guard let tokenData = token.data(using: self.textEncoding) else {
			throw KeychainError.encodingFailed
		}
		let attributes: QueryDictionary = [
			kSecValueData: tokenData,
			kSecAttrComment: comment as Any,
			kSecAttrLabel: server.absoluteString,
			kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
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
	
	/// Deletes token  for supplied URL
	/// - Parameter server: Service URL
	public func removeToken(server: URL) throws {
		let query = tokenQuery(for: server)
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else { throw SecError(status) }
	}
	
	/// Returns all stored URLs
	/// - Returns: Array of URLs
	public func getURLs() throws -> [URL] {
		var query = baseQuery
		query[kSecClass] = kSecClassInternetPassword
		query[kSecAttrDescription] = Self.tokenItemDescription
		query[kSecMatchLimit] = kSecMatchLimitAll
		query[kSecReturnAttributes] = true
		query[kSecReturnData] = false
		
		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status == errSecSuccess else {
			throw SecError(status)
		}
		
		guard let dict = item as? [[String: Any]] else {
			throw KeychainError.decodingFailed
		}
		
		let urls = dict
			.compactMap { $0[kSecAttrLabel as String] as? String }
			.compactMap { URL(string: $0) }

		return urls
	}
	
	// MARK: - Helpers
	
	internal static let tokenItemDescription = "Harbour - Token"

	/// Creates token query for supplied URL
	/// - Parameter server: Service URL
	/// - Returns: SecItem dictionary
	private func tokenQuery(for server: URL) -> QueryDictionary {
		var query = baseQuery
		query[kSecClass] = kSecClassInternetPassword
		query[kSecAttrDescription] = Self.tokenItemDescription
		query[kSecAttrServer] = server.absoluteString

		return query
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

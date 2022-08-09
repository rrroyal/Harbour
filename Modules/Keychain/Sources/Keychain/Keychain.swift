//
//  Keychain.swift
//  Keychain
//
//  Created by royal on 10/06/2021.
//

import Foundation
import Security

public final class Keychain {
	private typealias QueryDictionary = [CFString: Any]

	let service: String
	let accessGroup: String?

	private let baseQuery: QueryDictionary
	private let textEncoding: String.Encoding = .utf8
	private let tokenItemDescription = "Harbour - Token"


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
			kSecAttrSynchronizable: true,
			kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
			kSecClass: kSecClassInternetPassword,
			kSecAttrService: service
		]
	}

	// MARK: - Public functions

	/// Saves the token to keychain
	/// - Parameters:
	///   - server: Service URL
	///   - token: Account token
	public func saveToken(for server: URL, token: String) throws {
		var query = baseQuery
		query[kSecAttrServer] = server.host
		//		query[kSecAttrAccount] = server.absoluteString

//		guard let tokenData = token.data(using: self.textEncoding) else {
//			throw KeychainError.encodingFailed
//		}
		let attributes: QueryDictionary = [
			kSecValueData: token,
//			kSecAttrComment: comment as Any,
			kSecAttrPath: server.path,
			kSecAttrLabel: server.absoluteString,
			kSecAttrDescription: tokenItemDescription
		]
		try addOrUpdate(query: query, attributes: attributes)
	}

	/// Retrieves token
	/// - Parameter server: Service URL
	/// - Returns: Token
	public func getToken(for server: URL) throws -> String {
		var query = baseQuery
		query[kSecAttrServer] = server.host
		query[kSecMatchLimit] = kSecMatchLimitOne
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
		var query = baseQuery
		query[kSecAttrServer] = server.host
		let status = SecItemDelete(query as CFDictionary)
		guard status == errSecSuccess || status == errSecItemNotFound else { throw SecError(status) }
	}

	/// Returns all stored URLs
	/// - Returns: Array of URLs
	public func getURLs() throws -> [URL] {
		var query = baseQuery
//		query[kSecAttrDescription] = Self.tokenItemDescription
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

		let urls: [URL] = dict.compactMap {
			guard let string = $0[kSecAttrLabel as String] as? String else { return nil }
			return URL(string: string)
		}

		// TODO: Check if it works without `kSecAttrDescription`
		return urls
	}

	// MARK: - Helpers

	/// Adds or updates item with supplied query and attributes,
	/// - Parameters:
	///   - query: Item query
	///   - attributes: Item attributes
	private func addOrUpdate(query: QueryDictionary, attributes: QueryDictionary) throws {
		let addQuery = query.merging(attributes, uniquingKeysWith: { $1 })
		let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

		switch addStatus {
			case errSecSuccess:
				return
			case errSecDuplicateItem:
				let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
				guard updateStatus == errSecSuccess else {
					throw SecError(updateStatus)
				}
			default:
				throw SecError(addStatus)
		}
	}
}

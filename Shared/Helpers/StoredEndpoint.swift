//
//  StoredEndpoint.swift
//  Harbour
//
//  Created by royal on 10/01/2023.
//

import Foundation
import PortainerKit

public struct StoredEndpoint {
	public let id: Endpoint.ID
	public let name: String?
}

extension StoredEndpoint {
	enum CodingKeys: String, CodingKey {
		case id
		case name
	}
//
//	public init(from decoder: Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		self.id = try container.decode(Endpoint.ID.self, forKey: .id)
//		self.name = try container.decode(String.self, forKey: .name)
//	}
//
//	public func encode(to encoder: Encoder) throws {
//		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(self.id, forKey: .id)
//		try container.encode(self.name, forKey: .name)
//	}
}

extension StoredEndpoint: RawRepresentable {
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8),
			  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any?],
			  let id = result[CodingKeys.id.rawValue] as? Endpoint.ID else {
			return nil
		}
		let name = result[CodingKeys.name.rawValue] as? String
		self = .init(id: id, name: name)
	}

	public var rawValue: String {
		let dict: [String: Any?] = [
			CodingKeys.name.rawValue: self.name,
			CodingKeys.id.rawValue: self.id
		]
		guard let data = try? JSONSerialization.data(withJSONObject: dict),
			  let result = String(data: data, encoding: .utf8) else {
			return "{}"
		}
		return result
	}
}

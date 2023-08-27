//
//  StoredEndpoint.swift
//  Harbour
//
//  Created by royal on 10/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import PortainerKit

public struct StoredEndpoint: Identifiable, Codable {
	public let id: Endpoint.ID
	public let name: String?
}

extension StoredEndpoint {
	enum CodingKeys: String, CodingKey {
		case id
		case name
	}
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

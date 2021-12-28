//
//  Published+Decodable.swift
//  PortainerKit
//
//  Created by royal on 09/11/2021.
//

import Foundation

extension Published: Decodable where Value: Decodable {
	public init(from decoder: Decoder) throws {
		let decoded = try Value(from: decoder)
		self = Published(initialValue: decoded)
	}
}

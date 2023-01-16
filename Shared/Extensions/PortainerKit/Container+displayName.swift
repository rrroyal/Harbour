//
//  Container+displayName.swift
//  Harbour
//
//  Created by royal on 27/12/2022.
//

import Foundation
import PortainerKit

extension Container {
	var displayName: String? {
		guard let firstName = names?.first else { return nil }
		return firstName.starts(with: "/") ? String(firstName.dropFirst()) : firstName
	}
}

//
//  Portainer+DateError.swift
//  PortainerKit
//
//  Created by royal on 01/10/2022.
//

import Foundation

extension Portainer {
	enum DateError: Error {
		case invalidDate(dateString: String)
	}
}

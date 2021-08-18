//
//  Portainer+PortainerError.swift
//  Harbour
//
//  Created by unitears on 13/06/2021.
//

import Foundation

extension Portainer {
	enum PortainerError: Error {
		case noAPI
		case noEndpoint
		case noResponse
	}
}

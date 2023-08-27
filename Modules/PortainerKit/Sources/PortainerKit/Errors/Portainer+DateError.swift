//
//  Portainer+DateError.swift
//  PortainerKit
//
//  Created by royal on 01/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

extension Portainer {
	enum DateError: Error {
		case invalidDate(dateString: String)
	}
}

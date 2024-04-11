//
//  PortainerStore+Preview.swift
//  Harbour
//
//  Created by royal on 10/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

extension PortainerStore {
	static var preview: PortainerStore = {
		let portainerStore = PortainerStore()
		portainerStore.containers = [.preview]
		portainerStore.endpoints = [.init(id: 0, name: "Endpoint")]
		portainerStore.selectedEndpoint = portainerStore.endpoints.first
		return portainerStore
	}()
}

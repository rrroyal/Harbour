//
//  ContainerInspection.swift
//  PortainerKit
//
//  Created by royal on 23/07/2022.
//

import Foundation

public final class ContainerInspection: ObservableObject {
	@Published var container: Container
	@Published var inspection: ContainerDetails?

	init(container: Container, inspection: ContainerDetails? = nil) {
		self.container = container
		self.inspection = inspection
	}
}

//
//  ContainerDetailsView+NetworkSection.swift
//  Harbour
//
//  Created by royal on 07/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView+NetworkSection

extension ContainerDetailsView {
	struct NetworkSection: View {
		var ports: [PortainerKit.Port]?
		var networkSettings: Container.NetworkSettings?
		var detailNetworkSettings: ContainerDetails.NetworkSettings?

		var body: some View {
			Text("")
		}
	}
}

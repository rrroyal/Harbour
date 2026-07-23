//
//  CreateStackCreatorView.ViewModel+Types.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import Foundation
import PortainerKit

extension CreateStackCreatorView.ViewModel {
	struct Service: Identifiable, Hashable {
		var id: String { serviceName }

		var serviceName: String
		var containerName: String?
		var image: String
		var environment: [KeyValueEntry]
		var labels: [KeyValueEntry]
		var volumes: [Volume]
		var ports: [PortEntry]
		var networks: [Network]
		var networkMode: NetworkMode?
		var restartPolicy: RestartPolicy?
	}

	struct Network: Identifiable, Hashable {
		/// Network names must be unique within a stack
		var id: String { name }
		var name: String
		var external: Bool
	}
}

extension CreateStackCreatorView.ViewModel.Service {
	mutating func removeEnvironmentEntry(_ entry: KeyValueEntry) {
		environment.removeAll { $0 == entry }
	}

	mutating func removeLabel(_ entry: KeyValueEntry) {
		labels.removeAll { $0 == entry }
	}

	mutating func removeVolume(_ volume: Volume) {
		volumes.removeAll { $0.id == volume.id }
	}

	mutating func removePort(_ port: PortEntry) {
		ports.removeAll { $0.id == port.id }
	}

	mutating func removeNetwork(_ network: CreateStackCreatorView.ViewModel.Network) {
		networks.removeAll { $0 == network }
	}
}

extension CreateStackCreatorView.ViewModel.Service {
	struct Volume: Identifiable, Hashable {
		/// Container path - must be unique within a service
		var id: String { target }
		/// Host path or named volume
		var source: String
		/// Container path
		var target: String
	}

	struct PortEntry: Identifiable, Hashable {
		typealias Proto = PortainerKit.Port.PortType

		/// Container port + protocol - must be unique within a service
		var id: String { "\(containerPort)/\(proto.rawValue)" }
		var hostPort: UInt16
		var containerPort: UInt16
		var proto: Proto
	}

	/// Maps to Docker Compose's `network_mode` key.
	enum NetworkMode: String, CaseIterable, Identifiable, Hashable {
		var id: Self { self }

		case bridge
		case host
		case none
	}

	/// Maps to Docker Compose's `restart` key.
	enum RestartPolicy: String, CaseIterable, Identifiable, Hashable {
		var id: Self { self }

		case always
		case onFailure = "on-failure"
		case unlessStopped = "unless-stopped"
		case no
	}
}

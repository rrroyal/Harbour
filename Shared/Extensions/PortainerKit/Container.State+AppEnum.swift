//
//  Container.State+AppEnum.swift
//  Harbour
//
//  Created by royal on 11/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

extension Container.State: @retroactive AppEnum {
	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "PortainerKit.Container.State.AppEnumTitle")

	// swiftlint:disable colon
	public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.created:		.init(title: "PortainerKit.Container.State.Created", image: .init(systemName: "wake")),
		.running:		.init(title: "PortainerKit.Container.State.Running", image: .init(systemName: "power")),
		.paused:		.init(title: "PortainerKit.Container.State.Paused", image: .init(systemName: "pause")),
		.restarting:	.init(title: "PortainerKit.Container.State.Restarting", image: .init(systemName: "arrow.triangle.2.circlepath")),
		.removing:		.init(title: "PortainerKit.Container.State.Removing", image: .init(systemName: "trash")),
		.exited:		.init(title: "PortainerKit.Container.State.Exited", image: .init(systemName: "stop")),
		.dead:			.init(title: "PortainerKit.Container.State.Dead", image: .init(systemName: "xmark"))
	]
	// swiftlint:enable colon

	public static let allCases: [Container.State] = [
		.created,
		.running,
		.paused,
		.restarting,
		.removing,
		.exited,
		.dead
	]
}

// MARK: - ContainerStateAppEnum

// This should be removed when `Container.State+AppEnum` starts working properly
enum ContainerStateAppEnum: String {
	case created
	case running
	case paused
	case restarting
	case removing
	case exited
	case dead
}

// MARK: - ContainerStateAppEnum+PortainerKit

extension ContainerStateAppEnum {
	init(state: Container.State) {
		switch state {
		case .created: 		self = .created
		case .running: 		self = .running
		case .paused: 		self = .paused
		case .restarting: 	self = .restarting
		case .removing: 	self = .removing
		case .exited: 		self = .exited
		case .dead: 		self = .dead
		}
	}

	var portainerState: Container.State {
		switch self {
		case .created: 		.created
		case .running: 		.running
		case .paused: 		.paused
		case .restarting: 	.restarting
		case .removing: 	.removing
		case .exited: 		.exited
		case .dead: 		.dead
		}
	}
}

// MARK: - ContainerStateAppEnum+AppEnum

extension ContainerStateAppEnum: AppEnum {
	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "PortainerKit.Container.State.AppEnumTitle")

	// swiftlint:disable colon
	public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.created:		.init(title: "PortainerKit.Container.State.Created", image: .init(systemName: "wake")),
		.running:		.init(title: "PortainerKit.Container.State.Running", image: .init(systemName: "power")),
		.paused:		.init(title: "PortainerKit.Container.State.Paused", image: .init(systemName: "pause")),
		.restarting:	.init(title: "PortainerKit.Container.State.Restarting", image: .init(systemName: "arrow.triangle.2.circlepath")),
		.removing:		.init(title: "PortainerKit.Container.State.Removing", image: .init(systemName: "trash")),
		.exited:		.init(title: "PortainerKit.Container.State.Exited", image: .init(systemName: "stop")),
		.dead:			.init(title: "PortainerKit.Container.State.Dead", image: .init(systemName: "xmark"))
	]
	// swiftlint:enable colon
}

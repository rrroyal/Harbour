//
//  ContainerAction+AppEnum.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

// TODO: Remove `ContainerActionAppEnum` when it starts working properly

extension ContainerAction: @retroactive AppEnum {
	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "PortainerKit.ContainerAction.AppEnumTitle")

	// swiftlint:disable colon
	public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.start:		.init(title: "PortainerKit.ContainerAction.Start", image: .init(systemName: "play")),
		.stop:		.init(title: "PortainerKit.ContainerAction.Stop", image: .init(systemName: "stop")),
		.restart:	.init(title: "PortainerKit.ContainerAction.Restart", image: .init(systemName: "arrow.triangle.2.circlepath")),
		.kill:		.init(title: "PortainerKit.ContainerAction.Kill", image: .init(systemName: "bolt")),
		.pause:		.init(title: "PortainerKit.ContainerAction.Pause", image: .init(systemName: "pause")),
		.unpause:	.init(title: "PortainerKit.ContainerAction.Unpause", image: .init(systemName: "play"))
	]
	// swiftlint:enable colon

	public static let allCases: [Self] = [
		.start,
		.stop,
		.restart,
		.kill,
		.pause,
		.unpause
	]
}

// MARK: - ContainerActionAppEnum

enum ContainerActionAppEnum: String {
	case start
	case stop
	case restart
	case kill
	case pause
	case unpause
}

// MARK: - ContainerActionAppEnum+PortainerKit

extension ContainerActionAppEnum {
	init(action: ContainerAction) {
		switch action {
		case .start:	self = .start
		case .stop:		self = .stop
		case .restart:	self = .restart
		case .kill:		self = .kill
		case .pause:	self = .pause
		case .unpause:	self = .unpause
		}
	}

	var portainerAction: ContainerAction {
		switch self {
		case .start:	.start
		case .stop:		.stop
		case .restart:	.restart
		case .kill:		.kill
		case .pause:	.pause
		case .unpause:	.unpause
		}
	}
}

// MARK: - ContainerActionAppEnum+AppEnum

extension ContainerActionAppEnum: AppEnum {
	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "PortainerKit.ContainerAction.AppEnumTitle")

	// swiftlint:disable colon
	public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.start:		.init(title: "PortainerKit.ContainerAction.Start", image: .init(systemName: "play")),
		.stop:		.init(title: "PortainerKit.ContainerAction.Stop", image: .init(systemName: "stop")),
		.restart:	.init(title: "PortainerKit.ContainerAction.Restart", image: .init(systemName: "arrow.triangle.2.circlepath")),
		.kill:		.init(title: "PortainerKit.ContainerAction.Kill", image: .init(systemName: "bolt")),
		.pause:		.init(title: "PortainerKit.ContainerAction.Pause", image: .init(systemName: "pause")),
		.unpause:	.init(title: "PortainerKit.ContainerAction.Unpause", image: .init(systemName: "play"))
	]
	// swiftlint:enable colon
}

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

	public static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.created:		.init(title: "PortainerKit.Container.State.Created", image: .init(systemName: "wake")),
		.running:		.init(title: "PortainerKit.Container.State.Running", image: .init(systemName: "power")),
		.paused:		.init(title: "PortainerKit.Container.State.Paused", image: .init(systemName: "pause")),
		.restarting:	.init(title: "PortainerKit.Container.State.Restarting", image: .init(systemName: "arrow.triangle.2.circlepath")),
		.removing:		.init(title: "PortainerKit.Container.State.Removing", image: .init(systemName: "trash")),
		.exited:		.init(title: "PortainerKit.Container.State.Exited", image: .init(systemName: "stop")),
		.dead:			.init(title: "PortainerKit.Container.State.Dead", image: .init(systemName: "xmark"))
	]

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

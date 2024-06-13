//
//  ContainerAction+AppEnum.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import PortainerKit

extension ContainerAction: @retroactive AppEnum {
	public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "PortainerKit.ContainerAction.AppEnumTitle")

	public static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
		[
			.start:		.init(title: "PortainerKit.ContainerAction.Start", image: .init(systemName: "play")),
			.stop:		.init(title: "PortainerKit.ContainerAction.Stop", image: .init(systemName: "stop")),
			.restart:	.init(title: "PortainerKit.ContainerAction.Restart", image: .init(systemName: "arrow.triangle.2.circlepath")),
			.kill:		.init(title: "PortainerKit.ContainerAction.Kill", image: .init(systemName: "bolt")),
			.pause:		.init(title: "PortainerKit.ContainerAction.Pause", image: .init(systemName: "pause")),
			.unpause:	.init(title: "PortainerKit.ContainerAction.Unpause", image: .init(systemName: "play"))
		]
	}

	public static let allCases: [Self] = [
		.start,
		.stop,
		.restart,
		.kill,
		.pause,
		.unpause
	]
}

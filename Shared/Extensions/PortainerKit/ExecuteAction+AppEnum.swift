//
//  ExecuteAction+AppEnum.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//

import AppIntents
import PortainerKit

extension ExecuteAction: AppEnum {
	public static var typeDisplayRepresentation: TypeDisplayRepresentation = "PortainerKit.ExecuteAction.AppEnumTitle"

	public static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.start: .init(title: "PortainerKit.ExecuteAction.Start"),
		.stop: .init(title: "PortainerKit.ExecuteAction.Stop"),
		.restart: .init(title: "PortainerKit.ExecuteAction.Restart"),
		.kill: .init(title: "PortainerKit.ExecuteAction.Kill"),
		.pause: .init(title: "PortainerKit.ExecuteAction.Pause"),
		.unpause: .init(title: "PortainerKit.ExecuteAction.Unpause")
	]

	public static var allCases: [Self] = [
		.start,
		.stop,
		.restart,
		.kill,
		.pause,
		.unpause
	]
}

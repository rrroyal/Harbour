//
//  ExecuteAction+AppEnum.swift
//  Harbour
//
//  Created by royal on 09/07/2023.
//

import AppIntents
import PortainerKit

extension ExecuteAction: AppEnum {
	private typealias Localization = Localizable.PortainerKit.ExecuteAction

	public static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(stringLiteral: Localization.title)

	public static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
		.start: .init(stringLiteral: Localization.start),
		.stop: .init(stringLiteral: Localization.stop),
		.restart: .init(stringLiteral: Localization.restart),
		.kill: .init(stringLiteral: Localization.kill),
		.pause: .init(stringLiteral: Localization.pause),
		.unpause: .init(stringLiteral: Localization.unpause)
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

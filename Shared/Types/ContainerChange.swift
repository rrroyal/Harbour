//
//  ContainerChange.swift
//  Harbour
//
//  Created by royal on 03/02/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

struct ContainerChange: Codable, Hashable, Identifiable, Sendable {
	let id: Int
	let changeType: ChangeType
	let containerName: String

	let endpointID: Endpoint.ID

	let oldID: Container.ID?
	let oldState: Container.State?
	let oldStatus: String?

	let newID: Container.ID?
	let newState: Container.State?
	let newStatus: String?

	init(
		id: Int,
		changeType: ChangeType,
		containerName: String,
		endpointID: Endpoint.ID,
		oldID: Container.ID?,
		oldState: Container.State?,
		oldStatus: String?,
		newID: Container.ID?,
		newState: Container.State?,
		newStatus: String?
	) {
		self.id = id
		self.changeType = changeType
		self.containerName = containerName
		self.endpointID = endpointID
		self.oldID = oldID
		self.oldState = oldState
		self.oldStatus = oldStatus
		self.newID = newID
		self.newState = newState
		self.newStatus = newStatus
	}

	init?(oldContainer: Container?, newContainer: Container?, endpointID: Endpoint.ID, changeType: ChangeType) {
		guard oldContainer != nil || newContainer != nil else {
			return nil
		}

		if let oldContainer, let newContainer, oldContainer._persistentID != newContainer._persistentID {
			return nil
		}
		guard let oldPersistentID = oldContainer?._persistentID ?? newContainer?._persistentID else {
			return nil
		}
		self.id = oldPersistentID

		self.endpointID = endpointID
		self.changeType = changeType

		guard let containerName = newContainer?.displayName ?? oldContainer?.displayName ?? newContainer?.id ?? oldContainer?.id else {
			return nil
		}
		self.containerName = containerName

		self.oldID = oldContainer?.id
		self.oldState = oldContainer?.state
		self.oldStatus = oldContainer?.status

		self.newID = newContainer?.id
		self.newState = newContainer?.state
		self.newStatus = newContainer?.status
	}

	var changeEmoji: String {
		switch changeType {
		case .created:		newState.emoji
		case .recreated:	"♻️"
		case .changed:		newState.emoji
		case .removed:		"❌"
		}
	}

	var changeDescription: String {
		if let newStatus = self.newStatus {
			"\(self.newState.title), \(newStatus)"
		} else {
			self.newState.title
		}
	}
}

// MARK: - ContainerChange+ChangeType

extension ContainerChange {
	enum ChangeType: Codable, Hashable {
		case created
		case recreated
		case changed
		case removed

		var title: String {
			switch self {
			case .created:		String(localized: "ContainerChange.Created")
			case .recreated:	String(localized: "ContainerChange.Recreated")
			case .changed:		String(localized: "ContainerChange.Changed")
			case .removed:		String(localized: "ContainerChange.Removed")
			}
		}

		var icon: String {
			switch self {
			case .created:		"plus"
			case .recreated:	"arrow.triangle.2.circlepath"
			case .changed:		"arrow.left.arrow.right"
			case .removed:		"xmark"
			}
		}
	}
}

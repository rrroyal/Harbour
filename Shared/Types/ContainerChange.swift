//
//  ContainerChange.swift
//  Harbour
//
//  Created by royal on 03/02/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import PortainerKit

struct ContainerChange: Identifiable, Hashable, Sendable {
	let id: Int
	let changeType: ChangeType
	let containerName: String

	let endpointID: Endpoint.ID

	let oldID: Container.ID?
	let oldState: ContainerState?
	let oldStatus: String?

	let newID: Container.ID?
	let newState: ContainerState?
	let newStatus: String?

	init(
		id: Int,
		changeType: ChangeType,
		containerName: String,
		endpointID: Endpoint.ID,
		oldID: Container.ID?,
		oldState: ContainerState?,
		oldStatus: String?,
		newID: Container.ID?,
		newState: ContainerState?,
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

	var emoji: String {
		switch changeType {
		case .created:		newState.emoji
		case .recreated:	String(localized: "ContainerChange.Emoji.Recreated")
		case .changed:		newState.emoji
		case .removed:		String(localized: "ContainerChange.Emoji.Removed")
		}
	}
}

// MARK: - ContainerChange+ChangeType

extension ContainerChange {
	enum ChangeType {
		case changed
		case recreated
		case created
		case removed
	}
}

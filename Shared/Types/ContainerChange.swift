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

	let old: ChangeDetails?
	let new: ChangeDetails?

	init(
		id: Int,
		changeType: ChangeType,
		containerName: String,
		endpointID: Endpoint.ID,
		old: ChangeDetails?,
		new: ChangeDetails?
	) {
		self.id = id
		self.changeType = changeType
		self.containerName = containerName
		self.endpointID = endpointID
		self.old = old
		self.new = new
	}

	init?(oldContainer: Container?, newContainer: Container?, endpointID: Endpoint.ID, changeType: ChangeType) {
		guard oldContainer != nil || newContainer != nil else {
			return nil
		}

		if let oldContainer, let newContainer, oldContainer._persistentID != newContainer._persistentID {
			return nil
		}
		guard let persistentID = oldContainer?._persistentID ?? newContainer?._persistentID else {
			return nil
		}
		self.id = persistentID

		self.endpointID = endpointID
		self.changeType = changeType

		guard let containerName = newContainer?.displayName ?? oldContainer?.displayName ?? newContainer?.id ?? oldContainer?.id else {
			return nil
		}
		self.containerName = containerName

		self.old = .init(id: oldContainer?.id, state: oldContainer?.state, status: oldContainer?.status)
		self.new = .init(id: newContainer?.id, state: newContainer?.state, status: newContainer?.status)
	}

	var changeEmoji: String {
		switch changeType {
		case .created:		(new?.state ?? Container.State?.none).emoji
		case .recreated:	"♻️"
		case .changed:		(new?.state ?? Container.State?.none).emoji
		case .removed:		"❌"
		}
	}

	var changeDescription: String {
		if let newStatus = self.new?.status {
			"\((self.new?.state ?? Container.State?.none).title) • \(newStatus)"
		} else {
			(self.new?.state ?? Container.State?.none).title
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

// MARK: - ContainerChange+ChangeDetails

extension ContainerChange {
	struct ChangeDetails: Codable, Hashable {
		let id: Container.ID?
		let state: Container.State?
		let status: String?
	}
}

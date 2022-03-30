//
//  UserActivity.swift
//  Harbour
//
//  Created by royal on 29/03/2022.
//

import Foundation
import PortainerKit
import WidgetKit

protocol HBUserActivity {
	init?(from userActivity: NSUserActivity)

	static var activityType: String { get }
	static var requiredUserInfoKeys: Set<String> { get }

	func activity() -> NSUserActivity
}

struct UserActivity {
	enum UserInfoKey {
		static let containerID = "ContainerID"
		static let endpointID = "EndpointID"
	}
}

extension UserActivity {
	struct ViewContainer: HBUserActivity {
		static let activityType = "\(Bundle.main.bundleIdentifier!).ViewContainer"
		static let requiredUserInfoKeys: Set<String> = [UserInfoKey.containerID]

		let containerID: PortainerKit.Container.ID
		let containerDisplayName: String?
		let endpointID: PortainerKit.Endpoint.ID?

		init?(from userActivity: NSUserActivity) {
			guard let containerID = userActivity.userInfo?[UserInfoKey.containerID] as? String else {
				return nil
			}
			self.containerID = containerID
			self.containerDisplayName = nil
			self.endpointID = userActivity.userInfo?[UserInfoKey.endpointID] as? PortainerKit.Endpoint.ID
		}

		init(container: PortainerKit.Container) {
			self.containerID = container.id
			self.containerDisplayName = container.displayName
			self.endpointID = nil
		}

		func activity() -> NSUserActivity {
			let activity = NSUserActivity(activityType: Self.activityType)
			activity.requiredUserInfoKeys = Self.requiredUserInfoKeys
			activity.userInfo = [
				UserInfoKey.containerID: containerID,
				UserInfoKey.endpointID: endpointID as Any
			]
			activity.title = Localization.UserActivity.ViewContainer.title(containerDisplayName ?? containerID)
			activity.suggestedInvocationPhrase = activity.title
			activity.persistentIdentifier = "\(activity.activityType):\(containerID)"
			activity.isEligibleForPrediction = true
			activity.isEligibleForHandoff = true
			activity.isEligibleForSearch = true

			return activity
		}
	}

	struct AttachToContainer: HBUserActivity {
		static let activityType = "\(Bundle.main.bundleIdentifier!).AttachToContainer"
		static let requiredUserInfoKeys: Set<String> = [UserInfoKey.containerID]

		let containerID: PortainerKit.Container.ID
		let containerDisplayName: String?
		let endpointID: PortainerKit.Endpoint.ID?

		init?(from userActivity: NSUserActivity) {
			guard let containerID = userActivity.userInfo?[UserInfoKey.containerID] as? String else {
				return nil
			}
			self.containerID = containerID
			self.containerDisplayName = nil
			self.endpointID = userActivity.userInfo?[UserInfoKey.endpointID] as? PortainerKit.Endpoint.ID
		}

		#if IOS
		init(attachedContainer: Portainer.AttachedContainer) {
			self.containerID = attachedContainer.container.id
			self.containerDisplayName = attachedContainer.container.displayName
			self.endpointID = attachedContainer.endpointID
		}
		#endif

		func activity() -> NSUserActivity {
			let activity = NSUserActivity(activityType: Self.activityType)
			activity.requiredUserInfoKeys = Self.requiredUserInfoKeys
			activity.userInfo = [
				UserInfoKey.containerID: containerID,
				UserInfoKey.endpointID: endpointID as Any
			]
			activity.title = Localization.UserActivity.AttachToContainer.title(containerDisplayName ?? containerID)
			activity.suggestedInvocationPhrase = activity.title
			activity.persistentIdentifier = "\(activity.activityType):\(containerID)"
			activity.isEligibleForPrediction = true
			activity.isEligibleForHandoff = true
			activity.isEligibleForSearch = true

			return activity
		}
	}
}

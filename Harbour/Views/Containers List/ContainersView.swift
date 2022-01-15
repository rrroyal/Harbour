//
//  ContainersView.swift
//  Harbour
//
//  Created by royal on 21/10/2021.
//

import SwiftUI
import PortainerKit

struct ContainersView: View {
	@Environment(\.useContainerGridView) var useContainerGridView: Bool
	let containers: [ContainersStack]
	
    var body: some View {
		Self._printChanges()
		return Group {
			if useContainerGridView {
				ContainersGridView(containers: containers)
					.equatable()
			} else {
				ContainersListView(containers: containers)
					.equatable()
			}
		}
    }
}

extension ContainersView {
	static let stackBackground: Color = Color(uiColor: .systemGray6).opacity(0.5)
	
	static func containerDragProvider(container: PortainerKit.Container) -> NSItemProvider {
		let activity = NSUserActivity(activityType: AppState.UserActivity.viewContainer)
		activity.requiredUserInfoKeys = ["ContainerID"]
		activity.userInfo = ["ContainerID": container.id]
		activity.title = container.displayName ?? container.id
		activity.persistentIdentifier = container.id
		activity.isEligibleForPrediction = true
		activity.isEligibleForHandoff = true
		
		return NSItemProvider(object: activity)
	}
}

extension ContainersView {
	struct ContainersStack: Equatable {
		let stack: String?
		let containers: [PortainerKit.Container]
	}
}

extension ContainersView: Equatable {
	static func == (lhs: ContainersView, rhs: ContainersView) -> Bool {
		lhs.containers == rhs.containers
	}
}

struct ContainersView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersView(containers: [])
    }
}

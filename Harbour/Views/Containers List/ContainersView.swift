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
	let containers: [PortainerKit.Container]
	
    var body: some View {
		if useContainerGridView {
			ContainerGridView(containers: containers)
		} else {
			ContainerListView(containers: containers)
		}
    }
	
	static func containerDragProvider(container: PortainerKit.Container) -> NSItemProvider {
		let activity = NSUserActivity(activityType: AppState.UserActivity.viewingContainer)
		activity.requiredUserInfoKeys = ["ContainerID"]
		activity.userInfo = ["ContainerID": container.id]
		activity.title = container.displayName ?? container.id
		activity.persistentIdentifier = container.id
		activity.isEligibleForPrediction = true
		activity.isEligibleForHandoff = true
		
		return NSItemProvider(object: activity)
	}
}

struct ContainersView_Previews: PreviewProvider {
    static var previews: some View {
        ContainersView(containers: [])
    }
}

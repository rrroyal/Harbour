//
//  ContainerConsoleView.swift
//  Harbour
//
//  Created by royal on 13/06/2021.
//

import SwiftUI
import Combine
import PortainerKit

struct ContainerConsoleView: View {
	@ObservedObject var attachedContainer: Portainer.AttachedContainer
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.sceneErrorHandler) var sceneErrorHandler
		
	init(attachedContainer: Portainer.AttachedContainer) {
		self.attachedContainer = attachedContainer
		self.attachedContainer.errorHandler = sceneErrorHandler
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack {
					Group {
						if attachedContainer.attributedString.unicodeScalars.isEmpty {
							Text("Attached to \(attachedContainer.container.displayName ?? attachedContainer.container.id)!")
								.foregroundStyle(.secondary)
						} else {
							Text(attachedContainer.attributedString)
								.lineLimit(nil)
								.textSelection(.enabled)
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				}
				.font(.system(.footnote, design: .monospaced))
				.padding(.small)
			}
			.transition(.opacity)
			.navigationTitle(attachedContainer.container.displayName ?? attachedContainer.container.id)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button(role: .destructive, action: {
						UIDevice.generateHaptic(.soft)
						presentationMode.wrappedValue.dismiss()
					}) {
						if Preferences.shared.persistAttachedContainer {
							Label("Dismiss", systemImage: "chevron.down")
						} else {
							Label("Close", systemImage: "xmark")
						}
					}
				}
				
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(role: .destructive, action: {
						UIDevice.generateHaptic(.heavy)
						attachedContainer.disconnect()
						presentationMode.wrappedValue.dismiss()
					}) {
						Label("Disconnect", systemImage: "bolt")
							.symbolVariant(.slash)
					}
				}
			}
		}
		.userActivity(UserActivity.AttachToContainer.activityType, isActive: attachedContainer.isConnected && presentationMode.wrappedValue.isPresented) { activity in
			activity.requiredUserInfoKeys = UserActivity.AttachToContainer.requiredUserInfoKeys
			activity.userInfo = [
				UserActivity.UserInfoKey.containerID: attachedContainer.container.id,
				UserActivity.UserInfoKey.endpointID: attachedContainer.endpointID as Any
			]
			activity.title = Localization.UserActivity.AttachToContainer.title(attachedContainer.container.displayName ?? attachedContainer.container.id)
			activity.suggestedInvocationPhrase = activity.title
			activity.persistentIdentifier = "\(activity.activityType):\(attachedContainer.container.id)"
			activity.isEligibleForPrediction = true
			activity.isEligibleForHandoff = true
			activity.isEligibleForSearch = true
		}
	}
}

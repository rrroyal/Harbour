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
						if attachedContainer.buffer.isEmpty {
							Text("Attached to \(attachedContainer.container.displayName ?? attachedContainer.container.id)!")
								.foregroundStyle(.secondary)
						} else {
							Text(attachedContainer.buffer)
								.lineLimit(nil)
								.textSelection(.enabled)
						}
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				}
				.font(.system(.footnote, design: .monospaced))
				.padding(.small)
			}
			.animation(.easeInOut, value: attachedContainer.buffer.isEmpty)
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
		.userActivity(AppState.UserActivity.attachToContainer, isActive: attachedContainer.isConnected && presentationMode.wrappedValue.isPresented) { activity in
			activity.requiredUserInfoKeys = [AppState.UserActivity.containerIDKey]
			activity.userInfo = [
				AppState.UserActivity.containerIDKey: attachedContainer.container.id,
				AppState.UserActivity.endpointIDKey: attachedContainer.endpointID
			]
			activity.title = "Attach to \(attachedContainer.container.displayName ?? attachedContainer.container.id)".localized
			activity.suggestedInvocationPhrase = activity.title
			activity.persistentIdentifier = "\(AppState.UserActivity.attachToContainer):\(attachedContainer.container.id)"
			activity.isEligibleForPrediction = true
			activity.isEligibleForHandoff = true
			activity.isEligibleForSearch = true
		}
	}
}

//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import CommonOSLog
import CoreSpotlight
import KeychainKit
import OSLog
import PortainerKit
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - DebugView

struct DebugView: View {
	private nonisolated static let logger = Logger(.debug)

	var body: some View {
		Form {
			PortainerInfoSection()
			BackgroundSection()
			PersistenceSection()
			WidgetsSection()
			OtherSection()
		}
		.formStyle(.grouped)
		.navigationTitle("DebugView.Title")
	}
}

// MARK: - DebugView+PortainerInfoSection

private extension DebugView {
	struct PortainerInfoSection: View {
		@Environment(\.errorHandler) private var errorHandler
		@EnvironmentObject private var portainerStore: PortainerStore
		@State private var portainerSystemStatus: SystemStatus?
		@State private var portainerSystemVersion: SystemVersion?

		var body: some View {
			Section("DebugView.PortainerInfoSection.Title") {
				if let portainerSystemStatus {
					Group {
						LabeledContent(
							"DebugView.PortainerInfoSection.Status.Version",
							value: portainerSystemStatus.version
						)
						if let instanceID = portainerSystemStatus.instanceID, !instanceID.isEmpty {
							LabeledContent(
								"DebugView.PortainerInfoSection.Status.InstanceID",
								value: instanceID
							)
						}
					}
				}

				if let portainerSystemVersion {
					Group {
						if let latestVersion = portainerSystemVersion.latestVersion, !latestVersion.isEmpty {
							LabeledContent(
								"DebugView.PortainerInfoSection.Version.LatestVersion",
								value: latestVersion
							)
						}

						LabeledContent(
							"DebugView.PortainerInfoSection.Version.ServerEdition",
							value: portainerSystemVersion.serverEdition
						)

						if let serverVersion = portainerSystemVersion.serverVersion, !serverVersion.isEmpty {
							LabeledContent(
								"DebugView.PortainerInfoSection.Version.ServerVersion",
								value: serverVersion
							)
						}

						if let build = portainerSystemVersion.build {
							LabeledContent("DebugView.PortainerInfoSection.Version.Build.BuildNumber") {
								Text(build.buildNumber)
									.fontDesign(.monospaced)
									.textSelection(.enabled)
							}
						}

						if portainerSystemVersion.updateAvailable == true {
							if let url = URL(string: "https://docs.portainer.io/start/upgrade") {
								Link(destination: url) {
									Label("DebugView.PortainerInfoSection.Version.UpdateAvailable", systemImage: SFSymbol.external)
								}
							} else {
								Text("DebugView.PortainerInfoSection.Version.UpdateAvailable")
							}
						}
					}
				}
			}
			.task {
				async let systemStatus = try? portainerStore.fetchSystemStatus()
				async let systemVersion = try? portainerStore.fetchSystemVersion()

				self.portainerSystemStatus = await systemStatus
				self.portainerSystemVersion = await systemVersion
			}
			.animation(.default, value: portainerSystemStatus)
			.animation(.default, value: portainerSystemVersion)
		}
	}
}

// MARK: - DebugView+BackgroundSection

private extension DebugView {
	struct BackgroundSection: View {
		@Environment(\.errorHandler) private var errorHandler

		private var lastBackgroundRefreshDateString: String? {
			if let lastBackgroundRefreshDate = Preferences.shared.lastBackgroundRefreshDate {
				return Date(timeIntervalSince1970: lastBackgroundRefreshDate).formatted(.dateTime)
			}
			return nil
		}

		var body: some View {
			Section("DebugView.BackgroundSection.Title") {
				LabeledContent(
					"DebugView.BackgroundSection.LastBackgroundRefresh",
					value: lastBackgroundRefreshDateString ?? String(localized: "DebugView.BackgroundSection.LastBackgroundRefresh.Never")
				)

				Button("DebugView.BackgroundSection.SimulateBackgroundRefresh") {
					DebugView.logger.notice("Simulating background refresh...")
					Haptics.generateIfEnabled(.buttonPress)

					Task {
						await BackgroundHelper.handleBackgroundRefresh()
					}
				}
			}
		}
	}
}

// MARK: - DebugView+PersistenceSection

private extension DebugView {
	struct PersistenceSection: View {
		@Environment(\.errorHandler) private var errorHandler
		@Environment(\.modelContext) private var modelContext

		var body: some View {
			Section("DebugView.PersistenceSection.Title") {
				NavigationLink {
					UserDefaultsView()
				} label: {
					Text("DebugView.PersistenceSection.UserDefaults")
				}

				#if os(iOS)
				Button("DebugView.PersistenceSection.DeleteUserActivities", role: .destructive) {
					DebugView.logger.warning("Deleting saved user activities...")
					Haptics.generateIfEnabled(.heavy)
					UIApplication.shared.shortcutItems = nil
					NSUserActivity.deleteAllSavedUserActivities {
						DebugView.logger.notice("Deleted user activities!")
					}
				}
				.tint(.red)
				#endif

				Button("DebugView.PersistenceSection.ResetKeychain", role: .destructive) {
					DebugView.logger.warning("Resetting Keychain...")
					Haptics.generateIfEnabled(.heavy)
					do {
						let urls = try Keychain.shared.getSavedURLs()
						for url in urls {
							try Keychain.shared.removeContent(for: url)
						}
						DebugView.logger.notice("Keychain has been reset!")
					} catch {
						errorHandler(error)
					}
				}
				.tint(.red)

				Button("DebugView.PersistenceSection.ResetSpotlight", role: .destructive) {
					DebugView.logger.warning("Resetting Spotlight...")
					Haptics.generateIfEnabled(.heavy)
					CSSearchableIndex.default().deleteAllSearchableItems { error in
						if let error {
							DebugView.logger.error("Failed to reset Spotlight: \(error.localizedDescription, privacy: .public)")
							return
						}
						DebugView.logger.notice("Spotlight has been reset!")
					}
				}
				.tint(.red)

				Button("DebugView.PersistenceSection.ResetSwiftData", role: .destructive) {
					DebugView.logger.warning("Resetting SwiftData...")
					Haptics.generateIfEnabled(.heavy)

					modelContext.container.deleteAllData()
					DebugView.logger.notice("SwiftData has been reset!")
				}
				.tint(.red)
			}
		}
	}
}

// MARK: - DebugView+WidgetsSection

private extension DebugView {
	struct WidgetsSection: View {
		var body: some View {
			Section("DebugView.WidgetsSection.Title") {
				Button("DebugView.WidgetsSection.RefreshTimelines") {
					DebugView.logger.notice("Refreshing WidgetKit timelines...")
					Haptics.generateIfEnabled(.buttonPress)
					WidgetCenter.shared.reloadAllTimelines()
				}
			}
		}
	}
}

// MARK: - DebugView+OtherSection

private extension DebugView {
	struct OtherSection: View {
		var body: some View {
			Section {
				NavigationLink("DebugView.OtherSection.Logs") {
					DebugView.LogsView()
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	DebugView()
}

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
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - DebugView

struct DebugView: View {
	private let logger = Logger(.debug)

	var body: some View {
		Form {
			BackgroundSection()
			PersistenceSection()
			WidgetsSection()
			OtherSection()
		}
		.formStyle(.grouped)
		.navigationTitle("DebugView.Title")
	}
}

// MARK: - DebugView+BackgroundSection

private extension DebugView {
	struct BackgroundSection: View {
		@Environment(\.errorHandler) private var errorHandler

		private let logger = Logger(.debug)

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
					logger.notice("Simulating background refresh...")
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

		private let logger = Logger(.debug)

		var body: some View {
			Section("DebugView.PersistenceSection.Title") {
				NavigationLink {
					UserDefaultsView()
				} label: {
					Text("DebugView.PersistenceSection.UserDefaults")
				}

				#if os(iOS)
				Button("DebugView.PersistenceSection.DeleteUserActivities", role: .destructive) {
					logger.warning("Deleting saved user activities...")
					Haptics.generateIfEnabled(.heavy)
					UIApplication.shared.shortcutItems = nil
					NSUserActivity.deleteAllSavedUserActivities {
						logger.notice("Deleted user activities!")
					}
				}
				#endif

				Button("DebugView.PersistenceSection.ResetSpotlight", role: .destructive) {
					logger.warning("Resetting Spotlight...")
					Haptics.generateIfEnabled(.heavy)
					CSSearchableIndex.default().deleteAllSearchableItems { error in
						if let error {
							logger.error("Failed to reset Spotlight: \(error.localizedDescription, privacy: .public)")
							return
						}
						logger.notice("Spotlight has been reset!")
					}
				}

				Button("DebugView.PersistenceSection.ResetSwiftData", role: .destructive) {
					logger.warning("Resetting SwiftData...")
					Haptics.generateIfEnabled(.heavy)

					modelContext.container.deleteAllData()
					logger.notice("SwiftData has been reset!")
				}

				Button("DebugView.PersistenceSection.ResetKeychain", role: .destructive) {
					logger.warning("Resetting Keychain...")
					Haptics.generateIfEnabled(.heavy)
					do {
						let urls = try Keychain.shared.getSavedURLs()
						for url in urls {
							try Keychain.shared.removeContent(for: url)
						}
						logger.notice("Keychain has been reset!")
					} catch {
						errorHandler(error)
					}
				}
			}
		}
	}
}

// MARK: - DebugView+WidgetsSection

private extension DebugView {
	struct WidgetsSection: View {
		private let logger = Logger(.debug)

		var body: some View {
			Section("DebugView.WidgetsSection.Title") {
				Button("DebugView.WidgetsSection.RefreshTimelines") {
					logger.notice("Refreshing timelines...")
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

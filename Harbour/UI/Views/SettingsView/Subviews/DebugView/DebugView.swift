//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonHaptics
import CommonOSLog
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
			WidgetsSection()
			PersistenceSection()
			OtherSection()
		}
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
		.navigationTitle("DebugView.Title")
		.environment(\.logger, logger)
	}
}

// MARK: - DebugView+WidgetsSection

private extension DebugView {
	struct WidgetsSection: View {
		@Environment(\.logger) private var logger

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

// MARK: - DebugView+BackgroundSection

private extension DebugView {
	struct BackgroundSection: View {
		@Environment(\.errorHandler) private var errorHandler
		@Environment(\.logger) private var logger

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
		@Environment(\.logger) private var logger
		@Environment(\.errorHandler) private var errorHandler
		@Environment(\.modelContext) private var modelContext

		var body: some View {
			Section("DebugView.PersistenceSection.Title") {
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

				Button("DebugView.PersistenceSection.ResetSwiftData", role: .destructive) {
					logger.warning("Resetting SwiftData...")
					Haptics.generateIfEnabled(.heavy)
					Task { @MainActor in
						do {
							try modelContext.delete(model: StoredContainer.self)
							logger.notice("SwiftData has been reset!")
						} catch {
							errorHandler(error)
						}
					}
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

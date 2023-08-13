//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
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
		List {
			#if DEBUG
			BuildInfoSection()
			#endif
			WidgetsSection()
			PersistenceSection()
			OtherSection()
		}
		.navigationTitle("DebugView.Title")
		.environment(\.logger, logger)
	}
}

// MARK: - DebugView+Components

private extension DebugView {
	#if DEBUG
	struct BuildInfoSection: View {
		var body: some View {
			Section("DebugView.BuildInfoSection.Title") {
				LabeledContent("DebugView.BuildInfoSection.BuildDate", value: Bundle.main.infoDictionary?["BuildDate"] as? String ?? String(localized: "Generic.Unknown"))
			}
		}
	}
	#endif

	struct WidgetsSection: View {
		@Environment(\.logger) private var logger

		var body: some View {
			Section("DebugView.WidgetsSection.Title") {
				Button("DebugView.WidgetsSection.RefreshTimelines") {
					logger.debug("Refreshing timelines... [\(String._debugInfo(), privacy: .public)]")
					Haptics.generateIfEnabled(.buttonPress)
					WidgetCenter.shared.reloadAllTimelines()
				}
			}
		}
	}

	struct PersistenceSection: View {
		@Environment(\.logger) private var logger
		@Environment(\.errorHandler) private var errorHandler

		var lastBackgroundRefreshDateString: String {
			if let lastBackgroundRefreshDate = Preferences.shared.lastBackgroundRefreshDate {
				Date(timeIntervalSince1970: lastBackgroundRefreshDate).formatted(.dateTime)
			} else {
				String(localized: "DebugView.PersistenceSection.LastBackgroundRefresh.Never")
			}
		}

		var body: some View {
			Section("DebugView.PersistenceSection.Title") {
				LabeledContent("DebugView.PersistenceSection.LastBackgroundRefresh", value: lastBackgroundRefreshDateString)

				Button("DebugView.PersistenceSection.DeleteUserActivities", role: .destructive) {
					logger.debug("Deleting saved user activities... [\(String._debugInfo(), privacy: .public)]")
					Haptics.generateIfEnabled(.heavy)
					UIApplication.shared.shortcutItems = nil
					NSUserActivity.deleteAllSavedUserActivities {
						logger.debug("Deleted user activities! [\(String._debugInfo(), privacy: .public)]")
					}
				}

				Button("DebugView.PersistenceSection.ResetSwiftData", role: .destructive) {
					logger.debug("Resetting SwiftData... [\(String._debugInfo(), privacy: .public)]")
					Haptics.generateIfEnabled(.heavy)
					do {
						let model = try ModelContainer(for: StoredContainer.self)
						try model.mainContext.delete(model: StoredContainer.self)
						logger.debug("SwiftData has been reset! [\(String._debugInfo(), privacy: .public)]")
					} catch {
						errorHandler(error)
					}
				}

				Button("DebugView.PersistenceSection.ResetKeychain", role: .destructive) {
					logger.debug("Resetting Keychain... [\(String._debugInfo(), privacy: .public)]")
					Haptics.generateIfEnabled(.heavy)
					do {
						let urls = try Keychain.shared.getSavedURLs()
						for url in urls {
							try Keychain.shared.removeContent(for: url)
						}
						exit(0)
					} catch {
						errorHandler(error)
					}
				}
			}
		}
	}

	struct OtherSection: View {
		var body: some View {
			Section {
				NavigationLink("DebugView.OtherSection.Logs") {
					LogsView()
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	DebugView()
}

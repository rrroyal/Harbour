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
import SwiftUI
import WidgetKit

// MARK: - DebugView

struct DebugView: View {
	private let logger = Logger(category: Logger.Category.debug)

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
					logger.debug("Refreshing timelines... [\(String._debugInfo())]")
					Haptics.generateIfEnabled(.buttonPress)
					WidgetCenter.shared.reloadAllTimelines()
				}
			}
		}
	}

	struct PersistenceSection: View {
		@Environment(\.logger) private var logger
		@Environment(\.errorHandler) private var handleError

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
					logger.debug("Deleting saved user activities... [\(String._debugInfo())]")
					Haptics.generateIfEnabled(.heavy)
					UIApplication.shared.shortcutItems = nil
					NSUserActivity.deleteAllSavedUserActivities {
						logger.debug("Deleted user activities! [\(String._debugInfo())]")
					}
				}

				Button("DebugView.PersistenceSection.ResetCoreData", role: .destructive) {
					logger.debug("Resetting CoreData... [\(String._debugInfo())]")
					Haptics.generateIfEnabled(.heavy)
					Persistence.shared.reset()
				}

				Button("DebugView.PersistenceSection.ResetKeychain", role: .destructive) {
					logger.debug("Resetting Keychain... [\(String._debugInfo())]")
					Haptics.generateIfEnabled(.heavy)
					do {
						let urls = try Keychain.shared.getSavedURLs()
						for url in urls {
							try Keychain.shared.removeContent(for: url)
						}
						exit(0)
					} catch {
						handleError(error, ._debugInfo())
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

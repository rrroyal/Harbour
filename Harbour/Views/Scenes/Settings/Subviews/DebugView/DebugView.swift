//
//  DebugView.swift
//  Harbour
//
//  Created by royal on 02/10/2022.
//

import SwiftUI
import OSLog
import WidgetKit
import CommonHaptics
import CommonOSLog
import KeychainKit

// MARK: - DebugView

struct DebugView: View {
	private typealias Localization = Localizable.DebugView

	private let logger = Logger(category: Logger.Category.debug)

	var body: some View {
		List {
			#if DEBUG
			BuildInfoSection()
			LastBackgroundRefreshSection()
			#endif
			WidgetsSection()
			PersistenceSection()
			LogsSection()
		}
		.navigationTitle(Localization.title)
		.environment(\.logger, logger)
	}
}

// MARK: - DebugView+Components

private extension DebugView {
	#if DEBUG
	struct BuildInfoSection: View {
		var body: some View {
			Section("Build Info") {
				LabeledContent("Build Date", value: Bundle.main.infoDictionary?["BuildDate"] as? String ?? "Unknown")
			}
		}
	}

	struct LastBackgroundRefreshSection: View {
		var body: some View {
			Section(Localization.LastBackgroundRefresh.title) {
				if let lastBackgroundRefreshDate = Preferences.shared.lastBackgroundRefreshDate {
					Text(Date(timeIntervalSince1970: lastBackgroundRefreshDate), format: .dateTime)
				} else {
					Text(Localization.LastBackgroundRefresh.never)
						.foregroundStyle(.secondary)
				}
			}
		}
	}
	#endif

	struct WidgetsSection: View {
		@Environment(\.logger) private var logger

		var body: some View {
			Section("WidgetKit") {
				Button("Refresh timelines") {
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

		var body: some View {
			Section("Persistence") {
				Button("Delete User Activities") {
					logger.debug("Deleting saved user activities... [\(String._debugInfo())]")
					Haptics.generateIfEnabled(.heavy)
					NSUserActivity.deleteAllSavedUserActivities {
						logger.debug("Deleted user activities! [\(String._debugInfo())]")
					}
				}

				Button("Reset CoreData", role: .destructive) {
					logger.debug("Resetting CoreData... [\(String._debugInfo())]")
					Haptics.generateIfEnabled(.heavy)
					Persistence.shared.reset()
				}

				Button("Reset Keychain", role: .destructive) {
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

	struct LogsSection: View {
		var body: some View {
			Section {
				NavigationLink("Logs") {
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

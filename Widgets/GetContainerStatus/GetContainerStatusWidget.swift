//
//  GetContainerStatusWidget.swift
//  Widgets
//
//  Created by royal on 17/01/2022.
//

import WidgetKit
import PortainerKit

struct GetContainerStatusWidget {
	struct Provider: IntentTimelineProvider {
		func placeholder(in context: Context) -> Entry {
			let container = Portainer.PreviewData.container

			let configuration = GetContainerStatusIntent()
			configuration.container = Container(identifier: container.id, display: container.displayName ?? container.id, pronunciationHint: nil)
			
			return Entry(date: Date(), configuration: configuration, container: container)
		}
				
		func getSnapshot(for configuration: GetContainerStatusIntent, in context: Context, completion: @escaping (Entry) -> ()) {
			Widgets.logger.notice("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(configuration.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")

			if context.isPreview {
				let placeholder = placeholder(in: context)
				completion(placeholder)
				return
			}
			
			let now = Date()
			
			Task {
				do {
					guard let containerID = configuration.container?.identifier else { throw ProviderError.noContainerID }

					let portainer = try await Portainer.setup()
					let containers = try await portainer.getContainers()
					
					if Preferences.shared.enableBackgroundRefresh {
						portainer.checkDifferences()
					}
					
					let container = containers.first(where: { $0.id == containerID })
					Widgets.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(configuration.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash))) Container: \(container.debugDescription, privacy: .sensitive(mask: .hash))")

					let entry = Entry(date: now, configuration: configuration, container: container)
					completion(entry)
				} catch {
					Widgets.logger.error("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(configuration.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash))) Error! \(error.readableDescription, privacy: .public)")

					let entry = Entry(date: now, configuration: configuration, container: nil, error: error)
					completion(entry)
				}
			}
		}
		
		func getTimeline(for configuration: GetContainerStatusIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
			Widgets.logger.notice("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(configuration.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash)))")
			
			Task {
				let now = Date()

				do {
					guard let containerID = configuration.container?.identifier else { throw ProviderError.noContainerID }
					
					let portainer = try await Portainer.setup()
					let containers = try await portainer.getContainers()
					
					if Preferences.shared.enableBackgroundRefresh {
						portainer.checkDifferences()
					}
					
					let container = containers.first(where: { $0.id == containerID })
					Widgets.logger.info("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(configuration.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash))) Container: \(container.debugDescription, privacy: .public)")

					let entry = Entry(date: now, configuration: configuration, container: container)
					let timeline = Timeline(entries: [entry], policy: .atEnd)
					completion(timeline)
				} catch {
					Widgets.logger.error("\(#fileID, privacy: .public):\(#line, privacy: .public) \(#function, privacy: .public) (\(configuration.container?.identifier ?? "<none>", privacy: .sensitive(mask: .hash))) Error! \(error.readableDescription, privacy: .public)")

					let entry = Entry(date: now, configuration: configuration, container: nil, error: error)
					let timeline = Timeline(entries: [entry], policy: .atEnd)
					completion(timeline)
				}
			}
		}
	}
	
	struct Entry: TimelineEntry {
		let date: Date
		let configuration: GetContainerStatusIntent
		let container: PortainerKit.Container?
		let error: Error?
		
		internal init(date: Date, configuration: GetContainerStatusIntent, container: PortainerKit.Container?, error: Error? = nil) {
			self.date = date
			self.configuration = configuration
			self.container = container
			self.error = error
		}
	}
	
	enum ProviderError: Error {
		case noContainerID
		case containerNotFound
	}
}

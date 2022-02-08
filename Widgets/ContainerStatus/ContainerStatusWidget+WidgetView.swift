//
//  ContainerStatusWidget+WidgetView.swift
//  Widgets
//
//  Created by royal on 17/01/2022.
//

import WidgetKit
import SwiftUI
import PortainerKit

extension ContainerStatusWidget {
	struct WidgetView: View {
		let entry: ContainerStatusWidget.Entry
		
		@ViewBuilder
		var errorOverlay: some View {
			if let error = entry.error {
				Text("Error: \(error.readableDescription)")
					.font(.system(.footnote, design: .monospaced))
					.lineLimit(nil)
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.7)
					.padding()
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					.background(.ultraThinMaterial)
			}
		}
		
		var body: some View {
			if let containerID = entry.configuration.container?.identifier {
				ContainerView(entry: entry)
					.overlay(errorOverlay)
					.widgetURL(HarbourURLScheme.openContainer(containerID: containerID).url)
			} else {
				NoContainerView(entry: entry)
			}
		}
	}
}

private extension ContainerStatusWidget.WidgetView {
	struct ContainerView: View {
		let entry: ContainerStatusWidget.Entry
		let containerLabel: String?
		
		let circleSize: Double = 8
		
		init(entry: ContainerStatusWidget.Entry) {
			self.entry = entry
			self.containerLabel = entry.container?.displayName ?? entry.configuration.container?.displayString
		}
				
		var body: some View {
			VStack(spacing: 0) {
				HStack(alignment: .center) {
					Text(entry.container?.state?.rawValue.capitalizingFirstLetter ?? Localization.Generic.unknown)
						.font(.subheadline.weight(.medium))
						.foregroundStyle(entry.container?.state.color ?? Color(uiColor: .tertiaryLabel))
						.lineLimit(1)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Spacer()
					
					Circle()
						.fill(entry.container?.state.color ?? .clear)
						.frame(width: circleSize, height: circleSize)
				}
				.padding(.bottom, 2)
				
				Text(getFormattedDate(date: entry.date))
					.font(.caption2.weight(.medium))
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
				
				Spacer()
				
				Text(entry.container?.status ?? Localization.Widgets.unreachable)
					.font(.footnote.weight(.medium))
					.foregroundStyle(.secondary)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
				
				Text(containerLabel ?? Localization.Generic.unknown)
					.font(.title3.weight(.semibold))
					.foregroundColor(containerLabel != nil ? .primary : .secondary)
					.lineLimit(2)
					.minimumScaleFactor(0.6)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
			.padding()
		}
	}
	
	struct NoContainerView: View {
		let entry: ContainerStatusWidget.Provider.Entry
		
		var body: some View {
			Text(Localization.Widgets.selectContainer)
				.font(.headline)
				.multilineTextAlignment(.center)
				.padding()
		}
	}
	
	private static func getFormattedDate(date: Date) -> String {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.autoupdatingCurrent
		formatter.calendar = Calendar.autoupdatingCurrent
		
		formatter.doesRelativeDateFormatting = false
		formatter.formattingContext = .standalone
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		
		return formatter.string(from: date)
	}
}

struct ContainerStatusWidget_WidgetView_Previews: PreviewProvider {
	static var entry: ContainerStatusWidget.Entry = {
		let container: PortainerKit.Container? = nil
		
		let configuration = ContainerStatusIntent()
		configuration.container = Container(identifier: "ID", display: container?.displayName ?? container?.id ?? "DisplayName")
		
		let entry = ContainerStatusWidget.Entry(date: Date().addingTimeInterval(-1000), configuration: configuration, container: container)
		return entry
	}()
	
    static var previews: some View {
		ContainerStatusWidget.WidgetView(entry: entry)
			.previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

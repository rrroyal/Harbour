//
//  GetContainerStatusWidget+WidgetView.swift
//  Widgets
//
//  Created by royal on 17/01/2022.
//

import WidgetKit
import SwiftUI
import PortainerKit

extension GetContainerStatusWidget {
	struct WidgetView: View {
		let entry: GetContainerStatusWidget.Entry
		
		@ViewBuilder
		var errorOverlay: some View {
			if let error = entry.error {
				Text(error.readableDescription)
					.font(.system(.body, design: .monospaced))
					.lineLimit(nil)
					.multilineTextAlignment(.center)
					.minimumScaleFactor(0.7)
					.padding()
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
					.background(.thinMaterial)
			}
		}
		
		var body: some View {
			Group {
				if entry.configuration.container != nil {
					ContainerView(entry: entry)
				} else {
					NoContainerView(entry: entry)
				}
			}
			.overlay(errorOverlay)
		}
	}
}

private extension GetContainerStatusWidget.WidgetView {
	struct ContainerView: View {
		let entry: GetContainerStatusWidget.Entry
		let containerLabel: String?
		
		let circleSize: Double = 8
		
		init(entry: GetContainerStatusWidget.Entry) {
			self.entry = entry
			self.containerLabel = entry.container?.displayName ?? entry.configuration.container?.displayString
		}
				
		var body: some View {
			VStack(spacing: 0) {
				HStack(alignment: .center) {
					Text(entry.container?.state?.rawValue.capitalizingFirstLetter ?? "Unknown")
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
				
				Text(entry.container?.status ?? "Unreachable")
					.font(.footnote.weight(.medium))
					.foregroundStyle(.secondary)
					.lineLimit(1)
					.minimumScaleFactor(0.8)
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, alignment: .leading)
				
				Text(containerLabel ?? "Unknown")
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
		let entry: GetContainerStatusWidget.Provider.Entry
		
		var body: some View {
			Text("Select a container")
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

struct GetContainerStatusWidget_WidgetView_Previews: PreviewProvider {
	static var entry: GetContainerStatusWidget.Entry = {
		let container: PortainerKit.Container? = Portainer.PreviewData.container
		
		let configuration = GetContainerStatusIntent()
		configuration.container = Container(identifier: "ID", display: container?.displayName ?? container?.id ?? "DisplayName")
		
		let entry = GetContainerStatusWidget.Entry(date: Date().addingTimeInterval(-1000), configuration: configuration, container: container)
		return entry
	}()
	
    static var previews: some View {
		GetContainerStatusWidget.WidgetView(entry: entry)
			.previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

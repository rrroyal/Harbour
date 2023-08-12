//
//  ContainerDetailsView+SubviewsSection.swift
//  Harbour
//
//  Created by royal on 02/07/2023.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView+SubviewsSection

extension ContainerDetailsView {
	struct SubviewsSection: View {
		let container: Container?
		let details: ContainerDetails?
		let navigationItem: ContainerNavigationItem

		@ViewBuilder
		private var labelsSection: some View {
			let title = String(localized: "ContainerDetailsView.Section.Labels")
			let _data = details?.config?.labels

			NavigationLink {
				if let _data {
					let data = _data
						.map { IdentifiableTuple(key: $0, value: $1) }
						.sorted(by: \.key)

					DetailsListView(title, data: data) { entry in
						SectionMonospaced(entry.key) {
							Text(entry.value)
								.modifier(TextModifier())
						}
					}
				}
			} label: {
				Label(title, systemImage: "tag")
			}
			.disabled(_data == nil)
		}

		@ViewBuilder
		private var environmentSection: some View {
			let title = String(localized: "ContainerDetailsView.Section.Environment")
			let _data = details?.config?.env

			NavigationLink {
				if let _data {
					let data = _data
						.map { key -> IdentifiableTuple<String, String> in
							let split = key.split(separator: "=")
							if let one = split[safe: 0], let two = split[safe: 1] {
								return IdentifiableTuple(key: String(one), value: String(two))
							} else {
								return IdentifiableTuple(key: "", value: key)
							}
						}
						.sorted(by: \.key)

					DetailsListView(title, data: data) { entry in
						SectionMonospaced(entry.key) {
							Text(entry.value)
								.modifier(TextModifier())
						}
					}
				}
			} label: {
				Label(title, systemImage: "list.bullet.rectangle")
			}
			.disabled(_data == nil)
		}

		@ViewBuilder
		private var portsSection: some View {
			let title = String(localized: "ContainerDetailsView.Section.Ports")
			let _data = container?.ports

			NavigationLink {
				if let _data {
					let data = _data
						.map { entry -> IdentifiableTuple<String, String> in
							let privatePort = entry.privatePort ?? 0
							let publicPort = entry.publicPort ?? 0

							let key: String
							if let type = entry.type {
								key = "\(privatePort)/\(type.rawValue)"
							} else {
								key = "\(privatePort)"
							}

							let value: String
							if let ip = entry.ip {
								value = "\(ip):\(publicPort)"
							} else {
								value = "\(publicPort)"
							}

							return IdentifiableTuple(key: key, value: value)
						}
						.sorted(by: \.key)

					DetailsListView(title, data: data) { entry in
						SectionMonospaced(entry.key) {
							Text(entry.value)
								.modifier(TextModifier())
						}
					}
				}
			} label: {
				Label(title, systemImage: "externaldrive.connected.to.line.below")
			}
			.disabled(_data == nil)
		}

		@ViewBuilder
		private var mountsSection: some View {
			let title = String(localized: "ContainerDetailsView.Section.Mounts")
			let _data = details?.mounts

			NavigationLink {
				if let _data {
					let data = _data
						.map { IdentifiableTuple(key: $0.source, value: $0.destination) }
						.sorted(by: \.key)
					DetailsListView(title, data: data) { entry in
						SectionMonospaced(entry.key) {
							Text(entry.value)
								.modifier(TextModifier())
						}
					}
				}
			} label: {
				Label(title, systemImage: "externaldrive")
			}
			.disabled(_data == nil)
		}

		@ViewBuilder
		private var logsSection: some View {
			NavigationLink {
				ContainerLogsView(navigationItem: navigationItem)
			} label: {
				Label("ContainerDetailsView.Section.Logs", systemImage: SFSymbol.logs)
			}
		}

		var body: some View {
			Section {
				labelsSection
				environmentSection
				portsSection
				mountsSection
				logsSection
			}
		}
	}
}

// MARK: - ContainerDetailsView.SubviewsSection+TextModifier

private extension ContainerDetailsView.SubviewsSection {
	struct TextModifier: ViewModifier {
		func body(content: Content) -> some View {
			content
				.fontDesign(.monospaced)
				.frame(maxWidth: .infinity, alignment: .leading)
				.contentShape(Rectangle())
				.textSelection(.enabled)
		}
	}
}

// MARK: - ContainerDetailsView.SubviewsSection+SectionMonospaced

extension ContainerDetailsView.SubviewsSection {
	struct SectionMonospaced<Content: View>: View {
		let title: String
		let content: () -> Content

		init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
			self.title = title
			self.content = content
		}

		var body: some View {
			Section {
				content()
			} header: {
				Text(title)
					.textCase(.none)
					.fontDesign(.monospaced)
			}
		}
	}
}

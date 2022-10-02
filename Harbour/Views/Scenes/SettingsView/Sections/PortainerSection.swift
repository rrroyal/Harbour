//
//  PortainerSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI

// MARK: - SettingsView+PortainerSection

extension SettingsView {
	struct PortainerSection: View {
		@State private var isSetupSheetPresented: Bool = false

		var body: some View {
			Section(Localizable.Settings.Portainer.title) {
				EndpointsMenu(isSetupSheetPresented: $isSetupSheetPresented)
			}
			.sheet(isPresented: $isSetupSheetPresented) {
				SetupView()
			}
		}
	}
}

// MARK: - SettingsView.PortainerSection+Components

private extension SettingsView.PortainerSection {
	struct EndpointsMenu: View {
		private typealias Localization = Localizable.Settings.Portainer.EndpointsMenu

		@EnvironmentObject var portainerStore: PortainerStore
		@Binding var isSetupSheetPresented: Bool

		private var serverURLLabel: String? {
			guard let url = portainerStore.serverURL else { return nil }
			return formattedURL(url)
		}

		var body: some View {
			let urls = portainerStore.savedURLs.sorted { $0.absoluteString > $1.absoluteString }
			Menu(content: {
				ForEach(urls, id: \.absoluteString) { url in
					urlMenu(for: url)
				}

				Divider()

				Button(action: {
					UIDevice.generateHaptic(.sheetPresentation)
					isSetupSheetPresented = true
				}) {
					Label(Localization.add, systemImage: "plus")
				}
			}, label: {
				HStack {
//					SettingsView.OptionIcon(symbolName: "tag", color: .accentColor)
					Text(serverURLLabel ?? Localization.noServerPlaceholder)
						.font(SettingsView.standaloneLabelFont)

					Spacer()

					Image(systemName: "chevron.down")
						.fontWeight(.medium)
				}
			})
		}

		private func selectServer(_ url: URL) {
			// TODO: selectServer(_:)
			print(#function, url)
		}

		private func deleteServer(_ url: URL) {
			// TODO: deleteServer(_:)
			print(#function, url)
		}

		private func formattedURL(_ url: URL) -> String {
			if let scheme = url.scheme {
				return url.absoluteString.replacing("\(scheme)://", with: "")
			}
			return url.absoluteString
		}

		@ViewBuilder
		private func urlMenu(for url: URL) -> some View {
			Menu(formattedURL(url), content: {
				if portainerStore.serverURL == url {
					Label(Localization.Server.inUse, systemImage: "checkmark")
						.symbolVariant(.circle.fill)
				} else {
					Button(action: {
						UIDevice.generateHaptic(.buttonPress)
						selectServer(url)
					}, label: {
						Label(Localization.Server.use, systemImage: "checkmark")
							.symbolVariant(.circle)
					})
				}

				Divider()

				Button(role: .destructive, action: {
					UIDevice.generateHaptic(.buttonPress)
					deleteServer(url)
				}, label: {
					Label(Localization.Server.delete, systemImage: "trash")
				})
			})
		}
	}
}

// MARK: - Previews

struct PortainerSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.PortainerSection()
	}
}

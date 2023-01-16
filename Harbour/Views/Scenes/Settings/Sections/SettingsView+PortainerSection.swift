//
//  SettingsView+PortainerSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import CommonFoundation
import CommonHaptics

// MARK: - SettingsView+PortainerSection

extension SettingsView {
	struct PortainerSection: View {
		private typealias Localization = Localizable.Settings.Portainer

		@EnvironmentObject private var portainerStore: PortainerStore

		@State private var isSetupSheetPresented = false
		@State private var serverURLs: [URL] = PortainerStore.shared.savedURLs

		var body: some View {
			Section(Localization.title) {
				EndpointsMenu(isSetupSheetPresented: $isSetupSheetPresented, savedURLs: $serverURLs)
			}
			.sheet(isPresented: $isSetupSheetPresented, onDismiss: refreshServers) {
				SetupView()
			}
		}

		private func refreshServers() {
			serverURLs = portainerStore.savedURLs
		}
	}
}

// MARK: - SettingsView.PortainerSection+Components

private extension SettingsView.PortainerSection {
	struct EndpointsMenu: View {
		private typealias Localization = Localizable.Settings.Portainer.EndpointsMenu

		@EnvironmentObject private var portainerStore: PortainerStore
		@EnvironmentObject private var appState: AppState
		@Environment(\.sceneErrorHandler) private var sceneErrorHandler
		@Binding var isSetupSheetPresented: Bool
		@Binding var savedURLs: [URL]

		private var serverURLLabel: String? {
			guard let url = portainerStore.serverURL else { return nil }
			return formattedURL(url)
		}

		var body: some View {
			let urls = savedURLs.sorted { $0.absoluteString > $1.absoluteString }
			Menu(content: {
				ForEach(urls, id: \.absoluteString) { url in
					urlMenu(for: url)
				}

				Divider()

				Button(action: {
					Haptics.generateIfEnabled(.sheetPresentation)
					isSetupSheetPresented.toggle()
				}) {
					Label(Localization.add, systemImage: SFSymbol.add)
				}
			}) {
				HStack {
//					SettingsView.OptionIcon(symbolName: "tag", color: .accentColor)
					Text(serverURLLabel ?? Localization.noServerPlaceholder)
						.font(SettingsView.standaloneLabelFont)
						.foregroundStyle(serverURLLabel != nil ? .primary : .secondary)

					Spacer()

					Image(systemName: "chevron.down")
						.fontWeight(.medium)
				}
			}
		}

		@ViewBuilder
		private func urlMenu(for url: URL) -> some View {
			Menu(formattedURL(url), content: {
				if portainerStore.serverURL == url {
					Label(Localization.Server.inUse, systemImage: SFSymbol.selected)
						.symbolVariant(.circle.fill)
				} else {
					Button(action: {
						Haptics.generateIfEnabled(.buttonPress)
						appState.switchPortainerServer(to: url, errorHandler: sceneErrorHandler)
					}) {
						Label(Localization.Server.use, systemImage: SFSymbol.selected)
							.symbolVariant(.circle)
					}
				}

				Divider()

				Button(role: .destructive, action: {
					Haptics.generateIfEnabled(.buttonPress)
					deleteServer(url)
				}) {
					Label(Localization.Server.delete, systemImage: SFSymbol.remove)
				}
			})
		}

		private func deleteServer(_ url: URL) {
			do {
				try portainerStore.deleteServer(url)
				refreshServers()
			} catch {
				sceneErrorHandler?(error, ._debugInfo())
			}
		}

		private func formattedURL(_ url: URL) -> String {
			if let scheme = url.scheme {
				return url.absoluteString.replacing("\(scheme)://", with: "")
			}
			return url.absoluteString
		}

		private func refreshServers() {
			savedURLs = portainerStore.savedURLs
		}
	}
}

// MARK: - Previews

struct PortainerSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.PortainerSection()
	}
}

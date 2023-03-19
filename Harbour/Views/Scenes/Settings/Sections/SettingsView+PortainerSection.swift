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

		@EnvironmentObject private var viewModel: ViewModel

		var body: some View {
			Section(Localization.title) {
				EndpointsMenu()
			}
			.sheet(isPresented: $viewModel.isSetupSheetPresented, onDismiss: { viewModel.refreshServers() }) {
				SetupView()
			}
		}
	}
}

// MARK: - SettingsView.PortainerSection+Components

private extension SettingsView.PortainerSection {
	struct EndpointsMenu: View {
		private typealias Localization = Localizable.Settings.Portainer.EndpointsMenu

		@EnvironmentObject private var viewModel: SettingsView.ViewModel
		@Environment(\.sceneErrorHandler) private var sceneErrorHandler

		private var serverURLLabel: String? {
			guard let url = viewModel.activeURL else { return nil }
			return formattedURL(url)
		}

		var body: some View {
			let urls = viewModel.serverURLs.sorted { $0.absoluteString > $1.absoluteString }
			Menu(content: {
				ForEach(urls, id: \.absoluteString) { url in
					urlMenu(for: url)
				}

				Divider()

				Button(action: {
//					Haptics.generateIfEnabled(.sheetPresentation)
					viewModel.isSetupSheetPresented.toggle()
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

					Image(systemName: SFSymbol.chevronDown)
						.fontWeight(.medium)
				}
			}
		}

		@ViewBuilder
		private func urlMenu(for url: URL) -> some View {
			Menu(formattedURL(url), content: {
				if viewModel.activeURL == url {
					Label(Localization.Server.inUse, systemImage: SFSymbol.selected)
						.symbolVariant(.circle.fill)
				} else {
					Button(action: {
						Haptics.generateIfEnabled(.buttonPress)
						viewModel.switchPortainerServer(to: url, errorHandler: sceneErrorHandler)
					}) {
						Label(Localization.Server.use, systemImage: SFSymbol.selected)
							.symbolVariant(.circle)
					}
				}

				Divider()

				Button(role: .destructive, action: {
					Haptics.generateIfEnabled(.buttonPress)
					viewModel.deleteServer(url, errorHandler: sceneErrorHandler)
				}) {
					Label(Localization.Server.delete, systemImage: SFSymbol.remove)
				}
			})
		}

		private func formattedURL(_ url: URL) -> String {
			if let scheme = url.scheme {
				return url.absoluteString.replacing("\(scheme)://", with: "")
			}
			return url.absoluteString
		}
	}
}

// MARK: - Previews

struct PortainerSection_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView.PortainerSection()
	}
}

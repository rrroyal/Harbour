//
//  SettingsView+PortainerSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import KeychainKit
import SwiftUI

// MARK: - SettingsView+PortainerSection

extension SettingsView {
	struct PortainerSection: View {
		@Bindable var viewModel: SettingsView.ViewModel

		var body: some View {
			Section("SettingsView.Portainer.Title") {
				EndpointsMenu(viewModel: viewModel)
			}
			.sheet(isPresented: $viewModel.isSetupSheetPresented) {
				viewModel.refreshServers()
			} content: {
				SetupView()
			}
		}
	}
}

// MARK: - SettingsView.PortainerSection+Components

private extension SettingsView.PortainerSection {
	struct EndpointsMenu: View {
		@Environment(\.errorHandler) private var errorHandler
		@Bindable var viewModel: SettingsView.ViewModel

		private var serverURLLabel: String? {
			guard let url = viewModel.activeURL else { return nil }
			return formattedURL(url)
		}

		var body: some View {
			let urls = viewModel.serverURLs.sorted(by: \.absoluteString)
			Menu {
				ForEach(urls, id: \.absoluteString) { url in
					urlMenu(for: url)
				}

				Divider()

				Button {
//					Haptics.generateIfEnabled(.sheetPresentation)
					viewModel.isSetupSheetPresented.toggle()
				} label: {
					Label("SettingsView.Portainer.EndpointsMenu.Add", systemImage: SFSymbol.plus)
				}
			} label: {
				let _serverURLLabel = serverURLLabel ?? String(localized: "SettingsView.Portainer.EndpointsMenu.NoServerSelectedPlaceholder")
				HStack {
//					SettingsView.OptionIcon(symbolName: "tag", color: .accentColor)
					Text(_serverURLLabel)
						.font(SettingsView.labelFontHeadline)
						.foregroundStyle(serverURLLabel != nil ? .primary : .secondary)
						.lineLimit(1)

					Spacer()

					Image(systemName: SFSymbol.chevronDown)
						.fontWeight(.medium)
				}
				.transition(.opacity)
				.animation(.easeInOut, value: _serverURLLabel)
			}
			.confirmationDialog(
				"SettingsView.Portainer.EndpointRemovalAlert.Title",
				isPresented: $viewModel.isEndpointRemovalAlertPresented,
				presenting: viewModel.endpointToDelete
			) { url in
				Button("SettingsView.Portainer.EndpointRemovalAlert.RemoveButton", role: .destructive) {
					do {
						Haptics.generateIfEnabled(.heavy)
						try viewModel.removeServer(url)
						viewModel.endpointToDelete = nil
					} catch {
						errorHandler(error)
					}
				}
			} message: { url in
				Text("SettingsView.Portainer.EndpointRemovalAlert.Message URL:\(url.absoluteString)")
			}
		}

		@ViewBuilder
		private func urlMenu(for url: URL) -> some View {
			Menu(formattedURL(url), content: {
				if viewModel.activeURL == url {
					Label("SettingsView.Portainer.EndpointsMenu.Server.InUse", systemImage: SFSymbol.checkmark)
						.symbolVariant(.circle.fill)
				} else {
					Button {
						Haptics.generateIfEnabled(.buttonPress)
						viewModel.switchPortainerServer(to: url, errorHandler: errorHandler)
					} label: {
						Label("SettingsView.Portainer.EndpointsMenu.Server.Use", systemImage: SFSymbol.checkmark)
							.symbolVariant(.circle)
					}
				}

				#if DEBUG
				CopyButton("SettingsView.Portainer.EndpointsMenu.Server.CopyToken") {
					try? Keychain.shared.getString(for: url)
				}
				#endif

				Divider()

				Button(role: .destructive) {
					Haptics.generateIfEnabled(.warning)
					viewModel.endpointToDelete = url
					viewModel.isEndpointRemovalAlertPresented = true
				} label: {
					Label("SettingsView.Portainer.EndpointsMenu.Server.Remove", systemImage: SFSymbol.remove)
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

/*
#Preview {
	SettingsView.PortainerSection()
}
*/

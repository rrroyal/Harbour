//
//  SettingsView+ConnectionSection.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//  Copyright © 2023 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import KeychainKit
import SwiftUI

// MARK: - SettingsView+ConnectionSection

extension SettingsView {
	struct ConnectionSection: View {
		@EnvironmentObject private var preferences: Preferences
		@Environment(SettingsView.ViewModel.self) var viewModel

		var body: some View {
			Section("SettingsView.Connection.Title") {
				ConnectionMenu(viewModel: viewModel)
					.id(SettingsView.ViewID.connectionMenu)
			}
		}
	}
}

// MARK: - SettingsView.ConnectionSection+Components

private extension SettingsView.ConnectionSection {
	struct ConnectionMenu: View {
		@Environment(\.errorHandler) private var errorHandler
		@Bindable var viewModel: SettingsView.ViewModel

		private var serverURLLabel: String? {
			guard let url = viewModel.activeURL else { return nil }
			return formattedURL(url)
		}

		var body: some View {
			let urls = viewModel.serverURLs.localizedSorted(by: \.absoluteString)
			Menu {
				ForEach(urls, id: \.absoluteString) { url in
					URLMenu(url: url)
						.environment(viewModel)
				}

				Divider()

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					viewModel.isSetupSheetPresented = true
				} label: {
					Label("SettingsView.Connection.ConnectionMenu.Add", systemImage: SFSymbol.plus)
				}
			} label: {
				let _serverURLLabel = serverURLLabel ?? String(localized: "SettingsView.Connection.ConnectionMenu.NoServerSelectedPlaceholder")
				HStack {
//					SettingsView.OptionIcon(symbolName: "tag", color: .accentColor)
					Text(_serverURLLabel)
						.font(SettingsView.labelFontHeadline)
						#if os(macOS)
						.fontWeight(.regular)
						#endif
						.foregroundStyle(serverURLLabel != nil ? .primary : .secondary)
						.lineLimit(1)

					#if os(iOS)
					Spacer()

					Image(systemName: SFSymbol.chevronDown)
						.fontWeight(.medium)
						.foregroundStyle(.secondary)
					#endif
				}
				.transition(.opacity)
				.animation(.easeInOut, value: _serverURLLabel)
			}
			.labelStyle(.titleAndIcon)
			.confirmationDialog(
				"Generic.AreYouSure?",
				isPresented: $viewModel.isRemoveEndpointAlertVisible,
				titleVisibility: .visible,
				presenting: viewModel.endpointToRemove
			) { url in
				Button("Generic.Remove", role: .destructive) {
					Haptics.generateIfEnabled(.heavy)
					do {
						try viewModel.removeServer(url)
					} catch {
						errorHandler(error)
					}
					viewModel.endpointToRemove = nil
				}
			} message: { url in
				Text("SettingsView.Connection.RemoveEndpointAlert.Message URL:\(url.absoluteString)")
			}
		}
	}
}

// MARK: - SettingsView.ConnectionSection+Components

private extension SettingsView.ConnectionSection {
	private static func formattedURL(_ url: URL) -> String {
		if let scheme = url.scheme {
			return url.absoluteString.replacing("\(scheme)://", with: "")
		}
		return url.absoluteString
	}

	struct URLMenu: View {
		@Environment(SettingsView.ViewModel.self) private var viewModel
		@Environment(\.errorHandler) private var errorHandler
		@Environment(\.presentIndicator) private var presentIndicator
		var url: URL

		var body: some View {
			Menu {
				if viewModel.activeURL == url {
					Label("SettingsView.Connection.ConnectionMenu.Server.InUse", systemImage: SFSymbol.checkmark)
						.symbolVariant(.circle.fill)
				} else {
					Button {
						Haptics.generateIfEnabled(.light)
						presentIndicator(.serverSwitched(formattedURL(url)))
						viewModel.switchPortainerServer(to: url, errorHandler: errorHandler)

					} label: {
						Label("SettingsView.Connection.ConnectionMenu.Server.Use", systemImage: SFSymbol.checkmark)
							.symbolVariant(.circle)
					}
				}

				#if DEBUG
				CopyButton("SettingsView.Connection.ConnectionMenu.Server.CopyToken") {
					try? Keychain.shared.getString(for: url)
				}
				#endif

				Divider()

				Button(role: .destructive) {
					Haptics.generateIfEnabled(.warning)
					viewModel.endpointToRemove = url
					viewModel.isRemoveEndpointAlertVisible = true
				} label: {
					Label("SettingsView.Connection.ConnectionMenu.Server.Remove", systemImage: SFSymbol.remove)
				}
			} label: {
				Label(formattedURL(url), systemImage: SFSymbol.checkmark)
					.labelStyle(.iconOptional(showIcon: viewModel.activeURL == url))
			}
		}
	}
}

// MARK: - Previews

/*
#Preview {
	SettingsView.ConnectionSection()
}
*/

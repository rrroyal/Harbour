//
//  SettingsView+PortainerSection.swift
//  Harbour
//
//  Created by royal on 18/08/2021.
//

import SwiftUI
import UserNotifications

extension SettingsView {
	struct PortainerSection: View {
		@EnvironmentObject var appState: AppState
		@EnvironmentObject var sceneState: SceneState
		@EnvironmentObject var portainer: Portainer
		@EnvironmentObject var preferences: Preferences
		
		@State private var isLoginSheetPresented: Bool = false
		@State private var isLogoutWarningPresented: Bool = false
		
		var autoRefreshIntervalDescription: String {
			guard preferences.autoRefreshInterval > 0 else {
				return "Off"
			}
			
			let formatter = DateComponentsFormatter()
			formatter.allowedUnits = [.second]
			formatter.unitsStyle = .full
			
			return formatter.string(from: preferences.autoRefreshInterval) ?? "\(preferences.autoRefreshInterval) second(s)"
		}
		
		var serverMenu: some View {
			Menu(content: {
				ForEach(portainer.servers.sorted(by: { $0.absoluteString < $1.absoluteString }), id: \.absoluteString) { server in
					Menu(server.readableString) {
						if portainer.serverURL == server {
							Label("In use", systemImage: "checkmark")
								.symbolVariant(.circle.fill)
						} else {
							Button(action: {
								UIDevice.generateHaptic(.selectionChanged)
								Task {
									do {
										try await portainer.setup(with: server)
										try await portainer.getEndpoints()
									} catch {
										sceneState.handle(error)
									}
								}
							}) {
								Label("Use", systemImage: "checkmark")
									.symbolVariant(.circle)
							}
						}
						
						Divider()
						
						Button(role: .destructive, action: {
							UIDevice.generateHaptic(.heavy)
							do {
								try portainer.logout(from: server)
							} catch {
								sceneState.handle(error)
							}
						}) {
							Label("Delete", systemImage: "trash")
						}
					}
				}
				
				Divider()
				
				Button(action: {
					UIDevice.generateHaptic(.soft)
					isLoginSheetPresented = true
				}) {
					Label("Add", systemImage: "plus")
				}
			}) {
				HStack {
					OptionIcon(symbolName: "server.rack", color: .accentColor)
					
					Text(preferences.selectedServer?.readableString ?? "No server selected")
						.transition(.identity)
						.id("SelectedServerLabel-\(preferences.selectedServer?.absoluteString ?? "")")
					
					Spacer()
					
					Image(systemName: "chevron.down")
						.font(.body.weight(.semibold))
				}
			}
			.id("ServerSelectionMenu-\(portainer.servers.hashValue)")
			.font(standaloneLabelFont)
		}
		
		var body: some View {
			Group {
				Section("Portainer") {
					serverMenu
				}
				.sheet(isPresented: $isLoginSheetPresented) {
					LoginView()
				}
				
				Section("Data") {
					/// Persist attached container
					ToggleOption(label: Localization.Settings.Setting.PersistAttachedContainer.title, description: Localization.Settings.Setting.PersistAttachedContainer.description, iconSymbolName: "bolt", iconColor: .red, isOn: $preferences.persistAttachedContainer)
					
					/// Refresh containers in background
					ToggleOption(label: Localization.Settings.Setting.RefreshInBackground.title, description: Localization.Settings.Setting.RefreshInBackground.description, iconSymbolName: "arrow.clockwise", iconColor: .green, isOn: preferences.$enableBackgroundRefresh)
						.onChange(of: preferences.enableBackgroundRefresh, perform: setupBackgroundRefresh)
					
					/// Auto-refresh interval
					SliderOption(label: Localization.Settings.Setting.AutoRefresh.title, description: autoRefreshIntervalDescription, iconSymbolName: "clock.arrow.2.circlepath", iconColor: .cyan, value: $preferences.autoRefreshInterval, range: 0...60, step: 1, onEditingChanged: setupAutoRefreshTimer)
				}
			}
		}
		
		private func setupBackgroundRefresh(isOn: Bool) {
			guard isOn else {
				BackgroundTasks.cancelBackgroundRefreshTask()
				return
			}
			
			Task {
				do {
					try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
					BackgroundTasks.scheduleBackgroundRefreshTask()
				} catch {
					BackgroundTasks.cancelBackgroundRefreshTask()
					preferences.enableBackgroundRefresh = false
					sceneState.handle(error)
				}
			}
		}
		
		private func setupAutoRefreshTimer(isEditing: Bool) {
			guard !isEditing else { return }
			AppState.shared.setupAutoRefreshTimer(interval: preferences.autoRefreshInterval)
		}
	}
}

private extension URL {
	var readableString: String {
		guard let host = self.host else { return self.absoluteString }
		if let port = self.port {
			return "\(host):\(port)\(self.path)"
		} else {
			return "\(host)\(self.path)"
		}
	}
}

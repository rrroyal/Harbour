//
//  ContentView.swift
//  Harbour
//
//  Created by royal on 10/06/2021.
//

import PortainerKit
import SwiftUI
import Indicators

struct ContentView: View {
	@EnvironmentObject var appState: AppState
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var preferences: Preferences
	@Environment(\.scenePhase) var scenePhase
	@Environment(\.useColumns) var useColumns
	
	@StateObject private var sceneState: SceneState = SceneState()
	
	@State private var searchQuery: String = ""
	
	private var currentState: DataState {
		guard !(portainer.isFetchingEndpoints || portainer.isFetchingContainers || portainer.isSettingUp) else { return .fetching }
		guard portainer.isSetup && portainer.isLoggedIn else { return .notLoggedIn }
		guard !portainer.endpoints.isEmpty else { return .noEndpoints }
		guard portainer.selectedEndpointID != nil else { return .noEndpointSelected }
		guard !portainer.containers.isEmpty else { return .noContainers }
		return .finished
	}
	
	private var endpointButtonSymbolVariant: SymbolVariants {
		guard portainer.isSetup && portainer.isLoggedIn else { return .slash }
		if !portainer.endpoints.isEmpty && portainer.selectedEndpointID != nil { return .fill }
		if !portainer.endpoints.isEmpty { return .none }
		return .slash
	}
	
	var toolbarMenu: some View {
		Menu(content: {
			if !portainer.endpoints.isEmpty {
				ForEach(portainer.endpoints) { endpoint in
					Button(action: {
						setSelectedEndpoint(endpoint)
					}) {
						Text(endpoint.name ?? "\(endpoint.id)")
						if portainer.selectedEndpointID == endpoint.id {
							Image(systemName: "checkmark")
						}
					}
				}
			} else {
				Text("No endpoints")
			}
			
			Divider()
			
			Button(action: refresh) {
				Label("Refresh", systemImage: "arrow.clockwise")
			}
		}) {
			Label(portainer.endpoints.first(where: { $0.id == portainer.selectedEndpointID })?.name ?? "Endpoint", systemImage: "tag")
				.symbolVariant(endpointButtonSymbolVariant)
		}
		.disabled(!portainer.isSetup)
	}

	var background: some View {
		Color(uiColor: .systemGroupedBackground)
	}
	
	@ViewBuilder
	var content: some View {
		if portainer.containers.isEmpty {
			switch currentState {
				case .fetching:
					ProgressView()
				default:
					Text(currentState.label)
						.foregroundStyle(.tertiary)
						.id(currentState)
			}
		} else {
			ContainersView(containers: portainer.containers.sortedAndFiltered(query: searchQuery))
				.equatable()
				.searchable(text: $searchQuery)
		}
	}
	
	var body: some View {
		NavigationView {
			content
				.maxSize()
				.background(background.ignoresSafeArea())
				.transition(.opacity)
				.navigationTitle("Harbour")
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .navigation) {
						Button(action: {
							UIDevice.generateHaptic(.soft)
							sceneState.isSettingsSheetPresented = true
						}) {
							Image(systemName: "gear")
						}
					}
					
					ToolbarTitle(title: "Harbour", subtitle: (portainer.isFetchingEndpoints || portainer.isFetchingContainers || portainer.isSettingUp) ? Localization.Generic.fetching : nil)
					
					ToolbarItem(placement: .primaryAction, content: { toolbarMenu })
				}
			
			Text("Select container")
				.foregroundStyle(.tertiary)
		}
		.transition(.opacity)
		.animation(.easeInOut, value: portainer.isSetup)
		.animation(.easeInOut, value: portainer.selectedEndpointID)
		.animation(.easeInOut, value: portainer.containers)
		.animation(.easeInOut, value: currentState)
		.navigationViewStyle(useColumns: useColumns)
		.sheet(isPresented: $sceneState.isSettingsSheetPresented) {
			SettingsView()
		}
		.sheet(isPresented: $sceneState.isContainerConsoleSheetPresented, onDismiss: {
			DispatchQueue.main.async {
				sceneState.onContainerConsoleViewDismissed()
			}
		}) {
			if let attachedContainer = portainer.attachedContainer {
				ContainerConsoleView(attachedContainer: attachedContainer)
			}
		}
		.sheet(isPresented: $sceneState.isSetupSheetPresented, onDismiss: { Preferences.shared.finishedSetup = true }) {
			SetupView()
		}
		.indicatorOverlay(model: sceneState.indicators)
		.onChange(of: scenePhase, perform: onScenePhaseChange)
		.onContinueUserActivity(UserActivity.ViewContainer.activityType, perform: handleContinueUserActivity)
		.onContinueUserActivity(UserActivity.AttachToContainer.activityType, perform: handleContinueUserActivity)
		.onOpenURL(perform: onOpenURL)
		.onReceive(NotificationCenter.default.publisher(for: .DeviceDidShake, object: nil), perform: onDeviceDidShake)
		.environment(\.sceneErrorHandler, handleError)
		.environmentObject(sceneState)
	}
}

private extension ContentView {
	private func refresh() {
		UIDevice.generateHaptic(.light)
		Task {
			do {
				try await portainer.getEndpoints()
				try await portainer.getContainers()
			} catch {
				sceneState.handle(error)
			}
		}
	}

	private func setSelectedEndpoint(_ endpoint: PortainerKit.Endpoint) {
		UIDevice.generateHaptic(.light)
		Task {
			do {
				try await portainer.setSelectedEndpoint(endpoint.id)
			} catch {
				handleError(error)
			}
		}
	}

	private func onOpenURL(_ url: URL) {
		sceneState.onOpenURL(url)
	}

	private func onScenePhaseChange(_ scenePhase: ScenePhase) {
		switch scenePhase {
			case .active:
				Task {
					do {
						if !portainer.isSetup {
							try await portainer.setup()
							try await portainer.getEndpoints()
							if portainer.selectedEndpointID != nil {
								try await portainer.getContainers()
							}
						}
					} catch {
						handleError(error)
					}
				}
			case .background:
				if preferences.enableBackgroundRefresh {
					BackgroundTasks.scheduleBackgroundRefreshTask()
				}
			default:
				break
		}
	}

	private func onDeviceDidShake(_ notification: Notification) {
		guard portainer.attachedContainer != nil else { return }
		sceneState.showAttachedContainer()
	}

	private func handleContinueUserActivity(_ activity: NSUserActivity) {
		DispatchQueue.main.async {
			sceneState.handleContinueUserActivity(activity)
		}
	}

	private func handleError(_ error: Error, indicator: Indicators.Indicator? = nil, _fileID: StaticString = #fileID, _line: Int = #line, _function: StaticString = #function) {
		if let indicator = indicator {
			sceneState.handle(error, indicator: indicator, _fileID: _fileID, _line: _line, _function: _function)
		} else {
			sceneState.handle(error, _fileID: _fileID, _line: _line, _function: _function)
		}
	}
}

private extension ContentView {
	enum DataState {
		case finished
		case fetching
		case notLoggedIn
		case noEndpointSelected
		case noEndpoints
		case noContainers
		
		var label: String {
			switch self {
				case .fetching: return Localization.Generic.fetching
				case .notLoggedIn: return Localization.Generic.notLoggedIn
				case .noEndpointSelected: return Localization.Home.noEndpointSelected
				case .noEndpoints: return Localization.Home.noEndpoints
				case .noContainers: return Localization.Home.noContainers
				case .finished: return Localization.Home.finishedDebugDisclaimer
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(Portainer.shared)
	}
}

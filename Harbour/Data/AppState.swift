//
//  AppState.swift
//  Harbour
//
//  Created by unitears on 11/06/2021.
//

import Foundation
import Combine
import os.log
import UIKit
import Toasts

class AppState: ObservableObject {
	public static let shared: AppState = AppState()

	@Published public var activeContainerDetail: String? = nil
	@Published public var isContainerConsoleSheetPresented: Bool = false
	@Published public var isSetupSheetPresented: Bool = false
	
	@Published public var fetchingMainScreenData: Bool = false
	
	// TODO: Fix LoadingIndicator
	public var activeNetworkActivities: Set<String> = [] /* {
		didSet { UIApplication.shared.setLoadingIndicatorActive(!activeNetworkActivities.isEmpty) }
	} */
	
	public let toasts: Toasts = Toasts()

	private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppState")
	
	private var autoRefreshTimer: AnyCancellable? = nil

	private init() {
		#if DEBUG
		UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
		#endif
		
		if !Preferences.shared.launchedBefore {
			isSetupSheetPresented = true
		}
		
		if Preferences.shared.autoRefreshInterval > 0 {
			setupAutoRefreshTimer()
		}
	}
	
	// MARK: - Auto refresh
	
	public func setupAutoRefreshTimer(interval: Double = Preferences.shared.autoRefreshInterval) {
		self.logger.debug("(Auto refresh) Interval: \(interval)")
		
		autoRefreshTimer?.cancel()

		guard interval > 0 else { return }
		
		autoRefreshTimer = Timer.publish(every: interval, on: .current, in: .common)
			.autoconnect()
			.sink { _ in
				Task { [weak self] in
					DispatchQueue.main.async { [weak self] in
						self?.fetchingMainScreenData = true
					}
					
					do {
						guard let selectedEndpointID = Portainer.shared.selectedEndpoint?.id else {
							return
						}
						
						try await Portainer.shared.getContainers(endpointID: selectedEndpointID)
					} catch {
						await UIDevice.current.generateHaptic(.error)
						self?.handle(error)
					}
					
					DispatchQueue.main.async { [weak self] in
						self?.fetchingMainScreenData = false
					}
				}
			}
	}
	
	// MARK: - Error handling
	
	public func handle(_ error: Error, toast: Toasts.Toast, _fileID: StaticString = #fileID, _line: Int = #line) {
		handle(error, displayToast: false, _fileID: _fileID, _line: _line)
		DispatchQueue.main.async {
			self.toasts.add(toast)
		}
	}

	public func handle(_ error: Error, displayToast: Bool = true, _fileID: StaticString = #fileID, _line: Int = #line) {
		UIDevice.current.generateHaptic(.error)
		logger.error("\(String(describing: error)) [\(_fileID):\(_line)]")
		
		if displayToast {
			let toast: Toasts.Toast = .init(id: UUID().uuidString, dismissType: .after(5), icon: "exclamationmark.triangle", title: "Error!", description: error.localizedDescription, style: .color(foreground: .white, background: .red))
			DispatchQueue.main.async {
				self.toasts.add(toast)
			}
		}
	}
}

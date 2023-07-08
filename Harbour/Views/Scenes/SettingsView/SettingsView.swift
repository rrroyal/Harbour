//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import CommonHaptics
import SwiftUI

struct SettingsView: View {
	private typealias Localization = Localizable.SettingsView

	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@StateObject private var viewModel: ViewModel

	init() {
		let viewModel = ViewModel()
		self._viewModel = .init(wrappedValue: viewModel)
	}

	var body: some View {
		NavigationStack {
			List {
				PortainerSection()
				GeneralSection()
				InterfaceSection()
				OtherSection()
			}
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.navigationTitle(Localization.title)
			.toolbar {
				#if targetEnvironment(macCatalyst)
				ToolbarItem(placement: .cancellationAction) {
					Button(Localizable.Generic.close) {
//						Haptics.generateIfEnabled(.sheetPresentation)
						dismiss()
					}
				}
				#endif
			}
		}
		.environmentObject(viewModel)
	}
}

#Preview {
	SettingsView()
}

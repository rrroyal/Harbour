//
//  SettingsView.swift
//  Harbour
//
//  Created by royal on 23/07/2022.
//

import SwiftUI
import CommonHaptics

struct SettingsView: View {
	private typealias Localization = Localizable.Settings

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
				Group {
					PortainerSection()
					GeneralSection()
					InterfaceSection()
					OtherSection()
				}
				.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			}
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

struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
	}
}

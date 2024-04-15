//
//  CreateStackView+StackEnvironmentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - CreateStackView+StackEnvironmentView

extension CreateStackView {
	struct StackEnvironmentView: View {
		@Binding var environment: [KeyValueEntry]
		@Binding var isEnvironmentEntrySheetPresented: Bool
		@Binding var editedEnvironmentEntry: KeyValueEntry?
		var removeEntryAction: (KeyValueEntry) -> Void

		var environmentSorted: [KeyValueEntry] {
			environment.localizedSorted(by: \.key)
		}

		var body: some View {
			NormalizedSection {
				ForEach(environmentSorted) { entry in
					Button {
						Haptics.generateIfEnabled(.sheetPresentation)
						editedEnvironmentEntry = entry
						isEnvironmentEntrySheetPresented = true
					} label: {
						LabeledContent(entry.key, value: entry.value)
					}
					.fontDesign(.monospaced)
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							Haptics.generateIfEnabled(.selectionChanged)
							removeEntryAction(entry)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
					.transition(.opacity)
				}

				Button {
					Haptics.generateIfEnabled(.sheetPresentation)
					editedEnvironmentEntry = nil
					isEnvironmentEntrySheetPresented = true
				} label: {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackView.Environment")
			}
			.transition(.opacity)
			.animation(.easeInOut, value: environmentSorted)
		}
	}
}

// MARK: - Previews

#Preview {
	CreateStackView.StackEnvironmentView(
		environment: .constant([.init("key", "value")]),
		isEnvironmentEntrySheetPresented: .constant(false),
		editedEnvironmentEntry: .constant(nil),
		removeEntryAction: { _ in }
	)
}

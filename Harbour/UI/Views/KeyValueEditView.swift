//
//  KeyValueEditView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

// MARK: - KeyValueEditView

struct KeyValueEditView: View {
	static let presentationDetents: Set<PresentationDetent> = [.fraction(0.45)]

	@Environment(\.dismiss) private var dismiss
	var entry: KeyValueEntry?
	var saveAction: (KeyValueEntry) -> Void

	@FocusState private var focusedField: FocusedField?
	@State private var key: String
	@State private var value: String

	init(entry: KeyValueEntry?, saveAction: @escaping (KeyValueEntry) -> Void) {
		self.entry = entry
		self.key = entry?.key ?? ""
		self.value = entry?.value ?? ""
		self.saveAction = saveAction
	}

	private var canSave: Bool {
		!key.isReallyEmpty && !value.isReallyEmpty
	}

	var body: some View {
		VStack {
			TextFieldCell(title: String(localized: "EnvironmentEntryView.Key"), text: $key)
				.focused($focusedField, equals: .textfieldKey)
				.submitLabel(.next)
				.onSubmit {
					Haptics.generateIfEnabled(.selectionChanged)
					focusedField = .textfieldValue
				}
				.padding(.bottom)

			TextFieldCell(title: String(localized: "EnvironmentEntryView.Value"), text: $value)
				.focused($focusedField, equals: .textfieldValue)
				.submitLabel(.done)
				.onSubmit {
					if canSave {
						submit()
					}
				}

			Spacer()

			Button {
				submit()
			} label: {
				Label(
					entry != nil ? "Generic.Save" : "Generic.Add",
					systemImage: entry != nil ? SFSymbol.edit : SFSymbol.plus
				)
			}
			.buttonStyle(.customPrimary)
			.keyboardShortcut(.defaultAction)
			.disabled(!canSave)
			.transition(.opacity)
			.animation(.easeInOut, value: canSave)
		}
		.padding()
		.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
		.onAppear {
			focusedField = .textfieldKey
		}
	}
}

// MARK: - KeyValueEditView+Actions

private extension KeyValueEditView {
	func submit() {
		Haptics.generateIfEnabled(.light)
		saveAction(.init(key, value))
		dismiss()
	}
}

// MARK: - KeyValueEditView+TextFieldCell

private extension KeyValueEditView {
	struct TextFieldCell: View {
		var title: String
		@Binding var text: String

		var body: some View {
			VStack(alignment: .leading) {
				Text(title)
					.font(.footnote)
					.textCase(.uppercase)
					.foregroundStyle(.secondary)
					.padding(.leading)

				TextField(title, text: $text)
					.textFieldStyle(.rounded(backgroundColor: .secondaryGroupedBackground))
					.font(.callout)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
					.multilineTextAlignment(.leading)
			}
		}
	}
}

// MARK: - KeyValueEditView+FocusedField

private extension KeyValueEditView {
	enum FocusedField {
		case textfieldKey
		case textfieldValue
	}
}

// MARK: - Previews

#Preview("Create") {
	KeyValueEditView(entry: nil, saveAction: { _ in })
}

#Preview("Edit") {
	KeyValueEditView(entry: .init("", ""), saveAction: { _ in })
}

//
//  TextEditorView.swift
//  Harbour
//
//  Created by royal on 17/08/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

// MARK: - TextEditorView

struct TextEditorView: View {
	@Environment(\.dismiss) private var dismiss
	@Binding private var backingText: String
	@State private var text: String
	@State private var selection: TextSelection?
	@State private var isConfirmDismissDialogPresented = false
	@ScaledMetric(relativeTo: .body) private var fontSize: Double = 12
	@FocusState private var textFieldFocused: Bool
	private let navigationTitle: String

	init(text: Binding<String>, navigationTitle: String) {
		self._text = .init(initialValue: text.wrappedValue)
		self._backingText = text
		self.navigationTitle = navigationTitle
	}

	@ToolbarContentBuilder
	private var toolbarContent: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Group {
				#if os(iOS)
				CloseButton(style: .circleButton) {
					dismissWithConfirmation()
				}
				#elseif os(macOS)
				CloseButton(style: .text) {
					dismissWithConfirmation()
				}
				#endif
			}
			.confirmationDialog("Generic.AreYouSure", isPresented: $isConfirmDismissDialogPresented, titleVisibility: .visible) {
				Button("Generic.Discard", role: .destructive) {
					Haptics.generateIfEnabled(.heavy)
					dismiss()
				}
				.tint(.red)

				if #available(iOS 26.0, macOS 26.0, *) {
					Button("Generic.Cancel", role: .close) { }
				}
			} message: {
				Text("TextEditorView.ConfirmDismissDialog.Message")
			}
		}

//		let textIsSame = text == backingText
		ToolbarItem(placement: .primaryAction) {
			Button {
				Haptics.generateIfEnabled(.selectionChanged)
				backingText = text
				dismiss()
			} label: {
//				Text("Generic.Save")
				Label("Generic.Done", systemImage: SFSymbol.checkmark)
			}
			.buttonStyle(.borderedProminent)
			.tint(.accentColor)
//			.disabled(textIsSame)
//			.animation(.default, value: textIsSame)
		}

		#if os(iOS)
		if #available(iOS 26.0, macOS 26.0, *) {
			ToolbarItem(placement: .keyboard) {
				Button {
					insertAtCursor("\t")
				} label: {
					Label(String("⇥"), systemImage: "arrow.right.to.line")
				}
				.labelStyle(.iconOnly)
			}

			ToolbarSpacer(.flexible, placement: .keyboard)

			ToolbarItem(placement: .keyboard) {
				Button {
					textFieldFocused = false
				} label: {
					Label("Generic.DismissKeyboard", systemImage: "keyboard.chevron.compact.down")
				}
				.labelStyle(.iconOnly)
			}
		} else {
			ToolbarItem(placement: .keyboard) {
				HStack {
					Button {
						insertAtCursor("\t")
					} label: {
						Label(String("⇥"), systemImage: "arrow.right.to.line")
					}

					Spacer()

					Button {
						textFieldFocused = false
					} label: {
						Label("Generic.DismissKeyboard", systemImage: "keyboard.chevron.compact.down")
					}
				}
				.font(.footnote)
				.labelStyle(.iconOnly)
				.padding(.horizontal, -10)
			}
		}
		#endif
	}

	var body: some View {
		NavigationStack {
			TextEditor(text: $text, selection: $selection)
				.font(.system(size: fontSize))
				.fontDesign(.monospaced)
				#if os(iOS)
				.keyboardType(.alphabet)
				.textInputAutocapitalization(.never)
				#endif
				.autocorrectionDisabled()
//				.textSelectionAffinity(.downstream)
				.focused($textFieldFocused)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				.toolbar {
					toolbarContent
				}
				.navigationTitle(navigationTitle)
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
		}
		.interactiveDismissDisabled(text != backingText)
		#if os(iOS)
		.onAppear {
			selection = .init(insertionPoint: text.endIndex)
			textFieldFocused = true
		}
		#endif
	}
}

// MARK: - TextEditorView+Actions

private extension TextEditorView {
	func insertAtCursor(_ char: Character) {
		guard let selection, case .selection(let range) = selection.indices else {
			return
		}

		self.text.insert(char, at: range.lowerBound)

		let indexBefore = text.index(range.lowerBound, offsetBy: 1)
		self.selection = .init(insertionPoint: indexBefore)
	}

	func dismissWithConfirmation() {
		if text != backingText {
			Haptics.generateIfEnabled(.warning)
			isConfirmDismissDialogPresented = true
		} else {
			Haptics.generateIfEnabled(.buttonPress)
			dismiss()
		}
	}
}

// MARK: - Previews

#Preview {
	@Previewable @State var text: String = "Hello, world!"
	TextEditorView(text: $text, navigationTitle: "Text Editor")
}

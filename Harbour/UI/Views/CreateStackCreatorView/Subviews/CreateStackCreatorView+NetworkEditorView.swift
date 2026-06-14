//
//  CreateStackCreatorView+NetworkEditorView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension CreateStackCreatorView {
	struct NetworkEditorView: View {
		@Environment(\.dismiss) private var dismiss
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel

		var network: ViewModel.Network?
		var onDidSave: ((ViewModel.Network) -> Void)?

		@State private var name: String
		@State private var external: Bool
		@FocusState private var focusedField: Field?

		init(
			network: ViewModel.Network?,
			onDidSave: ((ViewModel.Network) -> Void)? = nil
		) {
			self.network = network
			self.onDidSave = onDidSave
			self._name = .init(initialValue: network?.name ?? "")
			self._external = .init(initialValue: network?.external ?? true)
		}

		var body: some View {
			Form {
				NameSection(
					name: $name,
					focusedField: $focusedField,
					onSubmit: saveNetwork
				)

				GeneralSettingsSection(
					external: $external
				)
			}
			.formStyle(.grouped)
			.scrollDismissesKeyboard(.interactively)
			.navigationTitle(network != nil ? "CreateStackCreatorView.NetworkEditorView.Title.Edit" : "CreateStackCreatorView.NetworkEditorView.Title.Add")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			#if os(iOS)
			.safeAreaInset(edge: .bottom) {
				HStack {
					if network != nil {
						Button(role: .destructive) {
							if let network {
								viewModel.removeNetwork(network)
							}
							dismiss()
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.buttonStyle(.customPrimary(backgroundColor: .red))
					}

					Button {
						saveNetwork()
					} label: {
						Label(
							network != nil ? "Generic.Save" : "Generic.Add",
							systemImage: network != nil ? SFSymbol.apply : SFSymbol.plus
						)
					}
					.keyboardShortcut(.defaultAction)
					.disabled(!canSave)
					.buttonStyle(.customPrimary)
				}
				._inGlassEffectContainer()
				.padding()
			}
			#endif
			.onAppear {
				if name.isEmpty {
					focusedField = .name
				}
			}
		}
	}
}

// MARK: - Helpers

private extension CreateStackCreatorView.NetworkEditorView {
	var canSave: Bool {
		!name.isReallyEmpty
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.NetworkEditorView {
	func saveNetwork() {
		guard canSave else { return }

		let entry = CreateStackCreatorView.ViewModel.Network(
			name: name
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.replacingOccurrences(of: " ", with: "-"),
			external: external
		)
		viewModel.saveNetwork(entry)
		onDidSave?(entry)

		dismiss()
	}
}

// MARK: - Subtypes

private extension CreateStackCreatorView.NetworkEditorView {
	enum Field {
		case name
	}
}

// MARK: - Subviews

private extension CreateStackCreatorView.NetworkEditorView {
	struct NameSection: View {
		@Binding var name: String
		@FocusState.Binding var focusedField: Field?
		let onSubmit: () -> Void

		var body: some View {
			NormalizedSection {
				TextField(
					String("my-network"),
					value: $name.replacing(" ", with: "-"),
					formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
				)
				.focused($focusedField, equals: .name)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
				.fontDesign(.monospaced)
				.labelsHidden()
				.submitLabel(.done)
				.onSubmit {
					focusedField = nil
					onSubmit()
				}
			} header: {
				Text("CreateStackCreatorView.NetworkEditorView.NameSection.Header")
			}
		}
	}

	struct GeneralSettingsSection: View {
		@Binding var external: Bool

		var body: some View {
			NormalizedSection {
				Toggle("CreateStackCreatorView.NetworkEditorView.GeneralSettingsSection.External", isOn: $external)
			}
		}
	}
}

// MARK: - Previews

#Preview("Add Network") {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	NavigationStack {
		CreateStackCreatorView.NetworkEditorView(network: nil)
	}
	.environment(CreateStackCreatorView.ViewModel(portainerStore: portainerStore))
}

#Preview("Edit Network") {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	let network = CreateStackCreatorView.ViewModel.Network(name: "my-network", external: true)
	NavigationStack {
		CreateStackCreatorView.NetworkEditorView(network: network)
	}
	.environment(CreateStackCreatorView.ViewModel(portainerStore: portainerStore))
}

//
//  CreateStackCreatorView+PortEntryEditView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension CreateStackCreatorView {
	struct PortEntryEditView: View {
		@Environment(\.dismiss) private var dismiss

		var entry: ViewModel.Service.PortEntry?
		var onSave: (ViewModel.Service.PortEntry) -> Void
		var removeAction: () -> Void

		@State private var hostPort: UInt16?
		@State private var containerPort: UInt16?
		@State private var proto: ViewModel.Service.PortEntry.Proto
		@FocusState private var focusedField: Field?

		private let numberFormatter = NumberFormatter()

		init(
			entry: ViewModel.Service.PortEntry?,
			onSave: @escaping (ViewModel.Service.PortEntry) -> Void,
			removeAction: @escaping () -> Void
		) {
			self.entry = entry
			self.onSave = onSave
			self.removeAction = removeAction
			self._hostPort = State(initialValue: entry?.hostPort)
			self._containerPort = State(initialValue: entry?.containerPort)
			self._proto = State(initialValue: entry?.proto ?? .tcp)
		}

		var body: some View {
			Form {
				NormalizedSection {
					TextField(
						"CreateStackView.ServiceEditor.Port.Host",
						value: $hostPort,
						formatter: numberFormatter
					)
					.focused($focusedField, equals: .hostPort)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.fontDesign(.monospaced)
					.labelsHidden()
					.keyboardType(.numberPad)
					.submitLabel(.next)
					.onSubmit {
						focusedField = .containerPort
					}
				} header: {
					Text("CreateStackView.ServiceEditor.Port.Host")
				} footer: {
					Text("CreateStackView.ServiceEditor.Port.Host.Footer")
				}

				NormalizedSection {
					TextField(
						"CreateStackView.ServiceEditor.Port.Container",
						value: $containerPort,
						formatter: numberFormatter
					)
					.focused($focusedField, equals: .containerPort)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.fontDesign(.monospaced)
					.labelsHidden()
					.keyboardType(.numberPad)
					.submitLabel(.done)
					.onSubmit { focusedField = nil }
				} header: {
					Text("CreateStackView.ServiceEditor.Port.Container")
				} footer: {
					Text("CreateStackView.ServiceEditor.Port.Container.Footer")
				}

				NormalizedSection {
					Picker("CreateStackView.ServiceEditor.Port.Protocol", selection: $proto) {
						ForEach(ViewModel.Service.PortEntry.Proto.allCases, id: \.self) { p in
							Text(p.rawValue.uppercased())
								.tag(p)
						}
					}
					.labelsHidden()
					#if os(iOS)
					.pickerStyle(.segmented)
					#endif
				} header: {
					Text("CreateStackView.ServiceEditor.Port.Protocol")
				}
			}
			.formStyle(.grouped)
			.scrollDisabled(true)
			.scrollDismissesKeyboard(.interactively)
			#if os(iOS)
			.safeAreaInset(edge: .bottom) {
				HStack {
					if entry != nil {
						Button(role: .destructive) {
							removeAction()
							dismiss()
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.buttonStyle(.customPrimary(backgroundColor: .red))
					}

					Button {
						saveEntry()
					} label: {
						Label(
							entry != nil ? "Generic.Save" : "Generic.Add",
							systemImage: entry != nil ? SFSymbol.apply : SFSymbol.plus
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
			.toolbar {
				#if os(macOS)
				ToolbarItem(placement: .primaryAction) {
					Button {
						saveEntry()
					} label: {
						Label(
							entry != nil ? "Generic.Save" : "Generic.Add",
							systemImage: entry != nil ? SFSymbol.apply : SFSymbol.plus
						)
					}
					.keyboardShortcut(.defaultAction)
					.disabled(!canSave)
				}
				if entry != nil {
					ToolbarItem(placement: .destructiveAction) {
						Button(role: .destructive) {
							removeAction()
							dismiss()
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.buttonStyle(.borderedProminent)
						.tint(.red)
					}
				}
				#endif
			}
			.onAppear {
				if hostPort == nil {
					focusedField = .hostPort
				}
			}
		}
	}
}

// MARK: - Helpers

private extension CreateStackCreatorView.PortEntryEditView {
	var canSave: Bool {
		hostPort ?? 0 > 0 && containerPort ?? 0 > 0
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.PortEntryEditView {
	func saveEntry() {
		guard canSave, let hostPort, let containerPort else { return }

		let entry = CreateStackCreatorView.ViewModel.Service.PortEntry(
			hostPort: hostPort,
			containerPort: containerPort,
			proto: proto
		)
		onSave(entry)

		dismiss()
	}
}

// MARK: - Subtypes

private extension CreateStackCreatorView.PortEntryEditView {
	enum Field {
		case hostPort
		case containerPort
	}
}

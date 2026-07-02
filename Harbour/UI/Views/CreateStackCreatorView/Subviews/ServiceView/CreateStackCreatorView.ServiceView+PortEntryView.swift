//
//  CreateStackCreatorView.ServiceView+PortEntryView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension CreateStackCreatorView.ServiceView {
	struct PortEntryView: View {
		@Environment(\.dismiss) private var dismiss

		var entry: CreateStackCreatorView.ViewModel.Service.PortEntry?
		var onSave: (CreateStackCreatorView.ViewModel.Service.PortEntry) -> Void
		var removeAction: () -> Void

		@State private var hostPort: UInt16?
		@State private var containerPort: UInt16?
		@State private var proto: CreateStackCreatorView.ViewModel.Service.PortEntry.Proto
		@FocusState private var focusedField: Field?

		private let numberFormatter = NumberFormatter()

		init(
			entry: CreateStackCreatorView.ViewModel.Service.PortEntry?,
			onSave: @escaping (CreateStackCreatorView.ViewModel.Service.PortEntry) -> Void,
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
						String("8080"),
						value: $hostPort,
						formatter: numberFormatter
					)
					.focused($focusedField, equals: .hostPort)
					.modifier(CreateStackCreatorView.TextFieldViewModifier())
					.keyboardType(.numberPad)
					.submitLabel(.next)
					.onSubmit {
						focusedField = .containerPort
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.PortEntryView.Host.Header")
				} footer: {
					Text("CreateStackCreatorView.ServiceView.PortEntryView.Host.Footer")
				}

				NormalizedSection {
					TextField(
						String("80"),
						value: $containerPort,
						formatter: numberFormatter
					)
					.focused($focusedField, equals: .containerPort)
					.modifier(CreateStackCreatorView.TextFieldViewModifier())
					.keyboardType(.numberPad)
					.submitLabel(.done)
					.onSubmit { focusedField = nil }
				} header: {
					Text("CreateStackCreatorView.ServiceView.PortEntryView.Container.Header")
				} footer: {
					Text("CreateStackCreatorView.ServiceView.PortEntryView.Container.Footer")
				}
			}
			.formStyle(.grouped)
			.scrollDisabled(true)
			.scrollDismissesKeyboard(.interactively)
			.safeAreaInset(edge: .top) {
				Picker("CreateStackCreatorView.ServiceView.PortEntryView.Protocol", selection: $proto) {
					ForEach(CreateStackCreatorView.ViewModel.Service.PortEntry.Proto.allCases, id: \.self) { p in
						Text(p.rawValue.uppercased())
							.tag(p)
					}
				}
				.labelsHidden()
				#if os(iOS)
				.pickerStyle(.segmented)
				#endif
				.padding(.top)
				.padding(.horizontal)
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						saveEntry()
					} label: {
						Label(
							entry != nil ? "Generic.Save" : "Generic.Add",
							systemImage: entry != nil ? SFSymbol.apply : SFSymbol.plus
						)
					}
					.buttonStyle(.borderedProminent)
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
						.keyboardShortcut(.delete)
					}
				}
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

private extension CreateStackCreatorView.ServiceView.PortEntryView {
	var canSave: Bool {
		hostPort ?? 0 > 0 && containerPort ?? 0 > 0
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.ServiceView.PortEntryView {
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

private extension CreateStackCreatorView.ServiceView.PortEntryView {
	enum Field {
		case hostPort
		case containerPort
	}
}

// MARK: - Previews

#Preview("Create") {
	CreateStackCreatorView.ServiceView.PortEntryView(
		entry: nil,
		onSave: { _ in },
		removeAction: { }
	)
}

#Preview("Edit") {
	CreateStackCreatorView.ServiceView.PortEntryView(
		entry: .init(hostPort: 8080, containerPort: 80, proto: .tcp),
		onSave: { _ in },
		removeAction: { }
	)
}

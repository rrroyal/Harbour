//
//  CreateStackCreatorView+ServiceView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension CreateStackCreatorView {
	struct ServiceView: View {
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel
		@Environment(\.dismiss) private var dismiss

		var service: ViewModel.Service?

		@State private var editedService: ViewModel.Service
		@State private var presentedSheet: Sheet?
		@FocusState private var focusedField: Field?

		init(service: ViewModel.Service?) {
			self.service = service
			self._editedService = State(
				initialValue: service ?? ViewModel.Service(
					serviceName: "",
					image: "",
					environment: [],
					labels: [],
					volumes: [],
					ports: [],
					networks: []
				)
			)
		}

		var body: some View {
			Form {
				GeneralSection(
					service: $editedService,
					focusedField: $focusedField
				)

				EnvironmentSection(
					environment: $editedService.environment,
					onAdd: { presentedSheet = .editEnvironment(nil) },
					onEdit: { presentedSheet = .editEnvironment($0) },
					onRemove: { entry in
						editedService.removeEnvironmentEntry(entry)
					}
				)

				LabelsSection(
					labels: $editedService.labels,
					onAdd: { presentedSheet = .editLabel(nil) },
					onEdit: { presentedSheet = .editLabel($0) },
					onRemove: { entry in
						editedService.removeLabel(entry)
					}
				)

				VolumesSection(
					volumes: $editedService.volumes,
					onAdd: { presentedSheet = .editVolume(nil) },
					onEdit: { presentedSheet = .editVolume($0) },
					onRemove: { volume in
						editedService.removeVolume(volume)
					}
				)

				PortsSection(
					ports: $editedService.ports,
					onAdd: { presentedSheet = .editPort(nil) },
					onEdit: { presentedSheet = .editPort($0) },
					onRemove: { port in
						editedService.removePort(port)
					}
				)

				NetworksSection(
					selectedNetworkIDs: .init {
						Set(editedService.networks.map(\.id))
					} set: { networkIDs in
						editedService.networks = viewModel.networks.filter { networkIDs.contains($0.id) }.sorted(by: \.name)
					},
					availableNetworks: viewModel.networks,
					onAdd: { presentedSheet = .editNetwork(nil) },
					onEdit: { presentedSheet = .editNetwork($0) },
					onRemove: { network in
						viewModel.removeNetwork(network)
						editedService.removeNetwork(network)
					}
				)
			}
			.formStyle(.grouped)
			.scrollDismissesKeyboard(.interactively)
			.navigationTitle(service != nil ? "CreateStackCreatorView.ServiceView.Title.Edit" : "CreateStackCreatorView.ServiceView.Title.Add")
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						saveService()
					} label: {
						Label(
							service != nil ? "Generic.Save" : "Generic.Add",
							systemImage: service != nil ? SFSymbol.apply : SFSymbol.plus
						)
					}
					.buttonStyle(.borderedProminent)
					.keyboardShortcut(.defaultAction)
					.disabled(!canSave)
					.animation(.default, value: canSave)
				}

				if service != nil {
					ToolbarItem(placement: .destructiveAction) {
						Button(role: .destructive) {
							if let service {
								viewModel.removeService(service)
							}
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
			.animation(.default, value: editedService.environment)
			.animation(.default, value: editedService.volumes)
			.animation(.default, value: editedService.ports)
			.animation(.default, value: editedService.networks)
			.sheet(item: $presentedSheet, content: sheetContent)
//			.onAppear {
//				if service == nil {
//					focusedField = .name
//				}
//			}
		}
	}
}

// MARK: - Helpers

private extension CreateStackCreatorView.ServiceView {
	var canSave: Bool {
		!editedService.serviceName.isReallyEmpty && !editedService.image.isReallyEmpty
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.ServiceView {
	func saveService() {
		guard canSave else { return }

		var editedService = editedService
		editedService.serviceName = editedService.serviceName.replacingOccurrences(of: " ", with: "-")
		editedService.image = editedService.image.replacingOccurrences(of: " ", with: "-")

		viewModel.saveService(editedService)

		dismiss()
	}
}

// MARK: - Types

extension CreateStackCreatorView.ServiceView {
	enum Field {
		case serviceName
		case containerName
		case image
	}
}

// MARK: - Subviews

private extension CreateStackCreatorView.ServiceView {
	@ViewBuilder
	func sheetContent(for sheet: Sheet) -> some View {
		@Bindable var viewModel = viewModel

		Group {
			switch sheet {
			case .editEnvironment(let entry):
				EditEnvironmentSheetContentView(
					entry: entry,
					environment: $editedService.environment,
					suggestions: .init(
						value: viewModel.stackEnvironment.map { "$\($0.key)" } // suggest environment keys from the stack
					)
				)
			case .editLabel(let entry):
				EditLabelSheetContentView(entry: entry, labels: $editedService.labels)
			case .editVolume(let volume):
				EditVolumeSheetContentView(volume: volume, volumes: $editedService.volumes)
			case .editPort(let port):
				EditPortSheetContentView(port: port, ports: $editedService.ports)
			case .editNetwork(let network):
				EditNetworkSheetContentView(
					network: network,
					networks: $viewModel.networks
				) { newNetwork in
					editedService.networks.append(newNetwork)
				}
			}
		}
		.modifier(CreateStackCreatorView.StyledSheetViewModifier())
	}
}

// MARK: - Previews

#Preview("Add Service") {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	NavigationStack {
		CreateStackCreatorView.ServiceView(service: nil)
	}
	.environment(CreateStackCreatorView.ViewModel(portainerStore: portainerStore))
}

#Preview("Edit Service") {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	let service = CreateStackCreatorView.ViewModel.Service(
		serviceName: "nginx",
		image: "nginx:latest",
		environment: [
			.init(key: "ENV_VAR", value: "value")
		],
		labels: [
			.init(key: "com.example.label", value: "label_value")
		],
		volumes: [
			.init(source: "/data", target: "/usr/share/nginx/html")
		],
		ports: [
			.init(
				hostPort: 8080,
				containerPort: 80,
				proto: .tcp
			)
		],
		networks: []
	)

	NavigationStack {
		CreateStackCreatorView.ServiceView(service: service)
	}
	.environment(CreateStackCreatorView.ViewModel(portainerStore: portainerStore))
}

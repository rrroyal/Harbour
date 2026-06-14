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
		@Environment(\.dismiss) private var dismiss
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel

		var service: ViewModel.Service?

		@State private var editedService: ViewModel.Service
		@State private var presentedSheet: Sheet?
		@FocusState private var focusedField: IdentitySection.FocusedField?

		init(service: ViewModel.Service?) {
			self.service = service
			self._editedService = State(initialValue: service ?? ViewModel.Service())
		}

		private var canSave: Bool {
			!editedService.name.isReallyEmpty && !editedService.image.isReallyEmpty
		}

		var body: some View {
			Form {
				IdentitySection(
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
					selectedNetworks: $editedService.networks,
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
			.sheet(item: $presentedSheet, content: sheetContent)
//			.onAppear {
//				if service == nil {
//					focusedField = .name
//				}
//			}
		}
	}
}

// MARK: - IdentitySection

extension CreateStackCreatorView.ServiceView {
	struct IdentitySection: View {
		@Binding var service: CreateStackCreatorView.ViewModel.Service
		@FocusState.Binding var focusedField: FocusedField?

		var body: some View {
			Group {
				NormalizedSection {
					TextField(
						String("service"),
						value: $service.name.replacing(" ", with: "-"),
						formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
					)
					.focused($focusedField, equals: .name)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.fontDesign(.monospaced)
					.labelsHidden()
					.submitLabel(.next)
					.onSubmit {
						focusedField = .image
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.Name")
				}

				NormalizedSection {
					TextField(
						String("image"),
						value: $service.image.replacing(" ", with: "-"),
						formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
					)
					.focused($focusedField, equals: .image)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.fontDesign(.monospaced)
					.labelsHidden()
					.submitLabel(.done)
					.onSubmit {
						focusedField = nil
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.Image")
				} footer: {
					Text("CreateStackCreatorView.ServiceView.Image.Footer")
				}
			}
		}

		enum FocusedField { case name, image }
	}
}

// MARK: - EnvironmentSection

extension CreateStackCreatorView.ServiceView {
	struct EnvironmentSection: View {
		@Binding var environment: [KeyValueEntry]
		var onAdd: () -> Void
		var onEdit: (KeyValueEntry) -> Void
		var onRemove: (KeyValueEntry) -> Void

		var body: some View {
			NormalizedSection {
				ForEach(environment) { entry in
					Button {
						onEdit(entry)
					} label: {
						LabeledContent {
							Text(entry.value).multilineTextAlignment(.trailing)
						} label: {
							Text(entry.key)
						}
					}
					.fontDesign(.monospaced)
					.contextMenu {
						Button(role: .destructive) {
							onRemove(entry)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.tint(.red)
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							onRemove(entry)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button(action: onAdd) {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackView.Environment")
			}
		}
	}
}

// MARK: - VolumesSection

extension CreateStackCreatorView.ServiceView {
	struct VolumesSection: View {
		@Binding var volumes: [CreateStackCreatorView.ViewModel.Service.Volume]
		var onAdd: () -> Void
		var onEdit: (CreateStackCreatorView.ViewModel.Service.Volume) -> Void
		var onRemove: (CreateStackCreatorView.ViewModel.Service.Volume) -> Void

		var body: some View {
			NormalizedSection {
				ForEach(volumes) { volume in
					Button {
						onEdit(volume)
					} label: {
						LabeledContent {
							Text(volume.target).multilineTextAlignment(.trailing)
						} label: {
							Text(volume.source)
						}
					}
					.fontDesign(.monospaced)
					.contextMenu {
						Button(role: .destructive) {
							onRemove(volume)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.tint(.red)
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							onRemove(volume)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button(action: onAdd) {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackCreatorView.ServiceView.Volumes")
			}
		}
	}
}

// MARK: - PortsSection

extension CreateStackCreatorView.ServiceView {
	struct PortsSection: View {
		@Binding var ports: [CreateStackCreatorView.ViewModel.Service.PortEntry]
		var onAdd: () -> Void
		var onEdit: (CreateStackCreatorView.ViewModel.Service.PortEntry) -> Void
		var onRemove: (CreateStackCreatorView.ViewModel.Service.PortEntry) -> Void

		var body: some View {
			NormalizedSection {
				ForEach(ports) { port in
					Button {
						onEdit(port)
					} label: {
						LabeledContent {
							Text(verbatim: "\(port.hostPort):\(port.containerPort)/\(port.proto.rawValue)")
								.fontDesign(.monospaced)
								.multilineTextAlignment(.trailing)
						} label: {
							Text("CreateStackCreatorView.ServiceView.PortEntryView.Label \(port.hostPort) \(port.containerPort)")
						}
					}
					.fontDesign(.monospaced)
					.contextMenu {
						Button(role: .destructive) {
							onRemove(port)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.tint(.red)
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							onRemove(port)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button(action: onAdd) {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackCreatorView.ServiceView.Ports")
			}
		}
	}
}

// MARK: - NetworksSection

extension CreateStackCreatorView.ServiceView {
	struct NetworksSection: View {
		@Binding var selectedNetworks: [CreateStackCreatorView.ViewModel.Network]
		var availableNetworks: [CreateStackCreatorView.ViewModel.Network]
		var onAdd: () -> Void
		var onEdit: (CreateStackCreatorView.ViewModel.Network) -> Void
		var onRemove: (CreateStackCreatorView.ViewModel.Network) -> Void

		var body: some View {
			NormalizedSection {
				ForEach(availableNetworks) { network in
					Toggle(isOn: Binding(
						get: { selectedNetworks.contains(network) },
						set: { include in
							if include {
								if !selectedNetworks.contains(network) {
									selectedNetworks.append(network)
								}
							} else {
								selectedNetworks.removeAll { $0 == network }
							}
						}
					)) {
						HStack {
							Text(network.name)
								.fontDesign(.monospaced)
						}
					}
					.contextMenu {
						Button {
							onEdit(network)
						} label: {
							Label("Generic.Edit", systemImage: SFSymbol.edit)
						}
						Button(role: .destructive) {
							onRemove(network)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.tint(.red)
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							onRemove(network)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button(action: onAdd) {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackCreatorView.ServiceView.Networks")
			}
		}
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.ServiceView {
	func saveService() {
		guard canSave else { return }
		var normalized = editedService
		normalized.name = normalized.name.replacingOccurrences(of: " ", with: "-")
		normalized.image = normalized.image.replacingOccurrences(of: " ", with: "-")
		viewModel.saveService(normalized)
		dismiss()
	}
}

// MARK: - Sheet

private extension CreateStackCreatorView.ServiceView {
	@ViewBuilder
	func sheetContent(for sheet: Sheet) -> some View {
		Group {
			switch sheet {
			case .editEnvironment(let entry):
				EditEnvironmentSheetContentView(entry: entry, environment: $editedService.environment)
			case .editVolume(let volume):
				EditVolumeSheetContentView(volume: volume, volumes: $editedService.volumes)
			case .editPort(let port):
				EditPortSheetContentView(port: port, ports: $editedService.ports)
			case .editNetwork(let network):
				EditNetworkSheetContentView(network: network, networks: $editedService.networks)
			}
		}
		.presentationDetents([.medium, .large])
		.presentationDetents([.medium, .large])
		.presentationDragIndicator(.hidden)
		.presentationContentInteraction(.resizes)
		.presentationContentInteraction(.resizes)
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
		name: "nginx",
		image: "nginx:latest",
		environment: [
			.init(key: "ENV_VAR", value: "value")
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
		]
	)

	NavigationStack {
		CreateStackCreatorView.ServiceView(service: service)
	}
	.environment(CreateStackCreatorView.ViewModel(portainerStore: portainerStore))
}

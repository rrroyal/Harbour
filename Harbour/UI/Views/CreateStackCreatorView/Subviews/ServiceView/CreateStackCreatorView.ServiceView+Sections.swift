//
//  CreateStackCreatorView.ServiceView+Sections.swift
//  Harbour
//
//  Created by royal on 15/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

extension CreateStackCreatorView.ServiceView {
	// MARK: - GeneralSection

	struct GeneralSection: View {
		@Binding var service: CreateStackCreatorView.ViewModel.Service
		@FocusState.Binding var focusedField: CreateStackCreatorView.ServiceView.Field?

		var body: some View {
			Group {
				NormalizedSection {
					TextField(
						String("my-service"),
						value: $service.serviceName.replacing(" ", with: "-"),
						formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
					)
					.focused($focusedField, equals: .serviceName)
					.modifier(CreateStackCreatorView.TextFieldViewModifier())
					.modifier(CreateStackCreatorView.RequiredValueViewModifier(hasValue: !service.serviceName.isReallyEmpty))
					.submitLabel(.next)
					.onSubmit {
						focusedField = .image
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.GeneralSection.ServiceName.Header")
				}

				NormalizedSection {
					TextField(
						String("my-image:tag"),
						value: $service.image.replacing(" ", with: "-"),
						formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
					)
					.focused($focusedField, equals: .image)
					.modifier(CreateStackCreatorView.TextFieldViewModifier())
					.modifier(CreateStackCreatorView.RequiredValueViewModifier(hasValue: !service.image.isReallyEmpty))
					.submitLabel(.next)
					.onSubmit {
						focusedField = .containerName
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.GeneralSection.Image.Header")
				}

				NormalizedSection {
					TextField(
						String("my-container"),
						text: $service.containerName.unwrapping(default: "")
					)
					.focused($focusedField, equals: .containerName)
					.modifier(CreateStackCreatorView.TextFieldViewModifier())
					.submitLabel(.done)
					.onSubmit {
						focusedField = nil
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.GeneralSection.ContainerName.Header")
				}

				NormalizedSection {
					Picker(selection: $service.networkMode) {
						ForEach(CreateStackCreatorView.ViewModel.Service.NetworkMode.allCases) { mode in
							Label(mode.title, systemImage: mode.symbolName)
								.tag(mode as CreateStackCreatorView.ViewModel.Service.NetworkMode?)
						}

						Divider()

						Text("Generic.Unspecified")
							.tag(nil as CreateStackCreatorView.ViewModel.Service.NetworkMode?)
					} label: {
						Text("CreateStackCreatorView.ServiceView.GeneralSection.Options.NetworkMode")
					}

					Picker(selection: $service.restartPolicy) {
						ForEach(CreateStackCreatorView.ViewModel.Service.RestartPolicy.allCases) { policy in
							Label(policy.title, systemImage: policy.symbolName)
								.tag(policy as CreateStackCreatorView.ViewModel.Service.RestartPolicy?)
						}

						Divider()

						Text("Generic.Unspecified")
							.tag(nil as CreateStackCreatorView.ViewModel.Service.RestartPolicy?)
					} label: {
						Text("CreateStackCreatorView.ServiceView.GeneralSection.Options.Restart")
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.GeneralSection.Options.Header")
				}
			}
		}
	}

	// MARK: - EnvironmentSection

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
							Text(entry.value)
								.multilineTextAlignment(.trailing)
						} label: {
							Text(entry.key)
						}
					}
					.fontDesign(.monospaced)
//					.contextMenu {
//						Button(role: .destructive) {
//							onRemove(entry)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.tint(.red)
//					}
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
				Text("CreateStackCreatorView.ServiceView.EnvironmentSection.Header")
			}
		}
	}

	// MARK: - LabelsSection

	struct LabelsSection: View {
		@Binding var labels: [KeyValueEntry]
		var onAdd: () -> Void
		var onEdit: (KeyValueEntry) -> Void
		var onRemove: (KeyValueEntry) -> Void

		var body: some View {
			NormalizedSection {
				ForEach(labels) { entry in
					Button {
						onEdit(entry)
					} label: {
						LabeledContent {
							Text(entry.value)
								.multilineTextAlignment(.trailing)
						} label: {
							Text(entry.key)
						}
					}
					.fontDesign(.monospaced)
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
				Text("CreateStackCreatorView.ServiceView.LabelsSection.Header")
			}
		}
	}

	// MARK: - VolumesSection

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
//					.contextMenu {
//						Button(role: .destructive) {
//							onRemove(volume)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.tint(.red)
//					}
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
				Text("CreateStackCreatorView.ServiceView.VolumesSection.Header")
			}
		}
	}

	// MARK: - PortsSection

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
							Text("CreateStackCreatorView.ServiceView.PortsSection.Port \(port.hostPort) \(port.containerPort)")
						}
					}
					.fontDesign(.monospaced)
//					.contextMenu {
//						Button(role: .destructive) {
//							onRemove(port)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.tint(.red)
//					}
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
				Text("CreateStackCreatorView.ServiceView.PortsSection.Header")
			}
		}
	}

	// MARK: - NetworksSection

	struct NetworksSection: View {
		@Binding var selectedNetworkIDs: Set<CreateStackCreatorView.ViewModel.Network.ID>
		var availableNetworks: [CreateStackCreatorView.ViewModel.Network]
		var onAdd: () -> Void
		var onEdit: (CreateStackCreatorView.ViewModel.Network) -> Void
		var onRemove: (CreateStackCreatorView.ViewModel.Network) -> Void

		var body: some View {
			NormalizedSection {
				ForEach(availableNetworks) { network in
					let isEnabled = selectedNetworkIDs.contains(network.id)

					Button {
						onEdit(network)
					} label: {
						Toggle(
							isOn: .init(
								get: { isEnabled },
								set: { include in
									if include {
										selectedNetworkIDs.insert(network.id)
									} else {
										selectedNetworkIDs.remove(network.id)
									}
								}
							)
						) {
							Text(network.name)
								.fontDesign(.monospaced)
						}
					}
//					.contextMenu {
//						Button {
//							onEdit(network)
//						} label: {
//							Label("Generic.Edit", systemImage: SFSymbol.edit)
//						}
//						Button(role: .destructive) {
//							onRemove(network)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.tint(.red)
//					}
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
				Text("CreateStackCreatorView.ServiceView.NetworksSection.Header")
			}
		}
	}
}

// MARK: - CreateStackCreatorView.ViewModel.Service.NetworkMode+title

extension CreateStackCreatorView.ViewModel.Service.NetworkMode {
	var title: LocalizedStringKey {
		switch self {
		case .bridge:
			"CreateStackCreatorView.ServiceView.NetworkMode.Bridge"
		case .host:
			"CreateStackCreatorView.ServiceView.NetworkMode.Host"
		case .none:
			"CreateStackCreatorView.ServiceView.NetworkMode.None"
		}
	}

	var symbolName: String {
		switch self {
		case .bridge:
			"point.3.connected.trianglepath.dotted"
		case .host:
			"network"
		case .none:
			SFSymbol.none
		}
	}
}

// MARK: - CreateStackCreatorView.ViewModel.Service.RestartPolicy+title

extension CreateStackCreatorView.ViewModel.Service.RestartPolicy {
	var title: LocalizedStringKey {
		switch self {
		case .always:
			"CreateStackCreatorView.ServiceView.RestartPolicy.Always"
		case .onFailure:
			"CreateStackCreatorView.ServiceView.RestartPolicy.OnFailure"
		case .unlessStopped:
			"CreateStackCreatorView.ServiceView.RestartPolicy.UnlessStopped"
		case .no:
			"CreateStackCreatorView.ServiceView.RestartPolicy.No"
		}
	}

	var symbolName: String {
		switch self {
		case .always:
			"arrow.trianglehead.2.clockwise.rotate.90"
		case .onFailure:
			"exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
		case .unlessStopped:
			"clock.arrow.trianglehead.2.counterclockwise.rotate.90"
		case .no:
			SFSymbol.none
		}
	}
}

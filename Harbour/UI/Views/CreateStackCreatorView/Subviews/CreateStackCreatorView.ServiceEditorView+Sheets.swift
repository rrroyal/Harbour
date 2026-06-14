//
//  CreateStackCreatorView.ServiceEditorView+Sheets.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import Foundation
import SwiftUI

extension CreateStackCreatorView.ServiceEditorView {
	enum Sheet: Identifiable {
		case editEnvironment(KeyValueEntry?)
		case editVolume(CreateStackCreatorView.ViewModel.Service.VolumeEntry?)
		case editPort(CreateStackCreatorView.ViewModel.Service.PortEntry?)
		case editNetwork(CreateStackCreatorView.ViewModel.Network?)

		var id: String {
			switch self {
			case .editEnvironment(let e): "env-\(e?.id ?? 0)"
			case .editVolume(let v): "vol-\(v?.id ?? "new")"
			case .editPort(let p): "port-\(p?.id ?? "new")"
			case .editNetwork(let n): "network-\(n?.id ?? "new")"
			}
		}
	}
}

// MARK: - EditEnvironmentSheetContentView

extension CreateStackCreatorView.ServiceEditorView {
	struct EditEnvironmentSheetContentView: View {
		var entry: KeyValueEntry?
		@Binding var environment: [KeyValueEntry]

		var body: some View {
			NavigationStack {
				KeyValueEditView(entry: entry) { newEntry in
					if let entry, let index = environment.firstIndex(of: entry) {
						environment[index] = newEntry
					} else {
						environment.append(newEntry)
					}
				} removeAction: {
					if let entry {
						environment.removeAll { $0 == entry }
					}
				}
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.navigationTitle(entry != nil ? "CreateStackView.EditEnvironmentValue" : "CreateStackView.AddEnvironmentValue")
				.addingCloseButton()
			}
		}
	}
}

// MARK: - EditVolumeSheetContentView

extension CreateStackCreatorView.ServiceEditorView {
	struct EditVolumeSheetContentView: View {
		typealias VolumeEntry = CreateStackCreatorView.ViewModel.Service.VolumeEntry

		var volume: VolumeEntry?
		@Binding var volumes: [VolumeEntry]

		var body: some View {
			NavigationStack {
				CreateStackCreatorView.VolumeEntryEditView(entry: volume) { newVolume in
					if let volume, let index = volumes.firstIndex(where: { $0.id == volume.id }) {
						volumes[index] = newVolume
					} else {
						volumes.append(newVolume)
					}
				} removeAction: {
					if let volume {
						volumes.removeAll { $0.id == volume.id }
					}
				}
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.navigationTitle(volume != nil ? "CreateStackView.ServiceEditor.EditVolume" : "CreateStackView.ServiceEditor.AddVolume")
				.addingCloseButton()
			}
		}
	}
}

// MARK: - EditPortSheetContentView

extension CreateStackCreatorView.ServiceEditorView {
	struct EditPortSheetContentView: View {
		typealias PortEntry = CreateStackCreatorView.ViewModel.Service.PortEntry

		var port: PortEntry?
		@Binding var ports: [PortEntry]

		var body: some View {
			NavigationStack {
				CreateStackCreatorView.PortEntryEditView(entry: port) { newPort in
					if let port, let index = ports.firstIndex(where: { $0.id == port.id }) {
						ports[index] = newPort
					} else {
						ports.append(newPort)
					}
				} removeAction: {
					if let port {
						ports.removeAll { $0.id == port.id }
					}
				}
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.navigationTitle(port != nil ? "CreateStackView.ServiceEditor.EditPort" : "CreateStackView.ServiceEditor.AddPort")
				.addingCloseButton()
			}
		}
	}
}

// MARK: - EditNetworkSheetContentView

extension CreateStackCreatorView.ServiceEditorView {
	struct EditNetworkSheetContentView: View {
		typealias Network = CreateStackCreatorView.ViewModel.Network

		var network: Network?
		@Binding var networks: [Network]

		var body: some View {
			NavigationStack {
				CreateStackCreatorView.NetworkEditorView(network: network) { newNetwork in
					if !networks.contains(newNetwork) {
						networks.append(newNetwork)
					}
				}
				.addingCloseButton()
			}
		}
	}
}

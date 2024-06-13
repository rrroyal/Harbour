//
//  ContainerDetailsView+NetworkDetailsView.swift
//  Harbour
//
//  Created by royal on 07/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import Navigation
import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView+NetworkDetailsView

extension ContainerDetailsView {
	struct NetworkDetailsView: View {
		var ports: [PortainerKit.Port]?
		var detailNetworkSettings: ContainerDetails.NetworkSettings?
		var exposedPorts: [String: [String: String]]?
		var portBindings: [String: [ContainerDetails.HostConfig.PortBinding]]?

		@ViewBuilder
		private var ipAddressSection: some View {
			if let ipAddress = detailNetworkSettings?.ipAddress, !ipAddress.isEmpty {
				NormalizedSection {
					ContainerDetailsView.Labeled(ipAddress)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.IPAddress")
				}
			}
		}

		@ViewBuilder
		private var portsSection: some View {
			PortsSection(
				ports: ports,
				exposedPorts: exposedPorts,
				portBindings: portBindings
			)
		}

		@ViewBuilder
		private var networksSection: some View {
			if let networks = detailNetworkSettings?.networks?.sorted(by: \.key), !networks.isEmpty {
				NormalizedSection {
					ForEach(Array(networks), id: \.key) { network in
						NavigationLink {
							NetworkDetailView(name: network.key, network: network.value)
						} label: {
							Text(network.key)
								.fontDesign(.monospaced)
								.textSelection(.enabled)
						}
					}
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.Networks")
				}
			}
		}

		@ViewBuilder
		private var backgroundPlaceholder: some View {
			if (ports?.isEmpty ?? true) && (exposedPorts?.isEmpty ?? true) && (portBindings?.isEmpty ?? true) && (detailNetworkSettings?.networks == nil) {
				ContentUnavailableView("Generic.Empty", systemImage: "ellipsis")
					.allowsHitTesting(false)
			}
		}

		var body: some View {
			Form {
//				ipAddressSection
				portsSection
				networksSection
			}
			.formStyle(.grouped)
			.scrollContentBackground(.hidden)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background {
				backgroundPlaceholder
			}
			#if os(iOS)
			.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
			#endif
			.navigationTitle("ContainerDetailsView.Section.Network")
		}
	}
}

// MARK: - ContainerDetailsView.NetworkDetailsView+NetworkDetailView

private extension ContainerDetailsView.NetworkDetailsView {
	struct NetworkDetailView: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		@EnvironmentObject private var portainerStore: PortainerStore
		var name: String
		var network: Network

		@ViewBuilder
		private var networkIDSection: some View {
			NormalizedSection {
				ContainerDetailsView.Labeled(network.networkID ?? String(localized: "Generic.Empty"))
					.fontDesign(.monospaced)
					.textSelection(.enabled)
			} header: {
				Text("ContainerDetailsView.NetworkDetailsView.NetworkID")
			}
		}

		@ViewBuilder
		private var gatewaySection: some View {
			if let gateway = network.gateway {
				NormalizedSection {
					ContainerDetailsView.Labeled(gateway)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.Gateway")
				}
			}
		}

		@ViewBuilder
		private var ipAddressSection: some View {
			if let ipAddress = network.ipAddress {
				NormalizedSection {
					ContainerDetailsView.Labeled(ipAddress)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.IPAddress")
				}
			}
		}

		@ViewBuilder
		private var macAddressSection: some View {
			if let macAddress = network.macAddress {
				NormalizedSection {
					ContainerDetailsView.Labeled(macAddress)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.MacAddress")
				}
			}
		}

		@ViewBuilder
		private var aliasesSection: some View {
			if let aliases = network.aliases, !aliases.isEmpty {
				NormalizedSection {
					ForEach(Set(aliases).localizedSorted(), id: \.self) { alias in
						ContainerDetailsView.Labeled(alias)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
					}
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.Aliases")
				}
			}
		}

		@ViewBuilder
		private var linksSection: some View {
			if let links = network.links, !links.isEmpty {
				let linksSplit: [KeyValueEntry] = Set(links)
					.compactMap { link in
						let split = link.split(separator: ":")
						guard let partOne = split[safe: 0], let partTwo = split[safe: 1] else { return nil }
						return KeyValueEntry(key: String(partOne), value: String(partTwo))
					}
					.sorted { ($0.key, $0.value) < ($1.key, $1.value) }

				NormalizedSection {
					ForEach(linksSplit, id: \.self) { link in
						LabeledContent {
							Text(link.value)
						} label: {
							if let foundContainer = portainerStore.containers.first(where: { $0.namesNormalized?.contains(link.key) ?? false }) {
								Button(link.key) {
									let navigationItem = ContainerDetailsView.NavigationItem(
										id: foundContainer.id,
										displayName: foundContainer.displayName ?? link.key
									)
									sceneDelegate.navigate(to: .containers, with: navigationItem)
								}
								#if os(macOS)
								.buttonStyle(.plain)
								.foregroundStyle(.accent)
								#endif
							} else {
								Text(link.key)
							}
						}
						.fontDesign(.monospaced)
						.textSelection(.enabled)
					}
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.Links")
				}
			}
		}

		var body: some View {
			Form {
				networkIDSection
				gatewaySection
				ipAddressSection
				macAddressSection
				aliasesSection
				linksSection
			}
			.formStyle(.grouped)
			.navigationTitle(name)
		}
	}
}

// MARK: - ContainerDetailsView.NetworkDetailsView+PortsSection

private extension ContainerDetailsView.NetworkDetailsView {
	struct PortsSection: View {
		@EnvironmentObject private var portainerStore: PortainerStore
		var ports: [PortainerKit.Port]?
		var exposedPorts: [String: [String: String]]?
		var portBindings: [String: [ContainerDetails.HostConfig.PortBinding]]?

		private var entries: [Entry] {
			var mappedPorts = Set<Int>()

			let ports: [Entry] = self.ports?.compactMap {
				guard let entry = Entry(port: $0) else { return nil }

				mappedPorts.insert(entry.containerPort)
				return entry
			} ?? []

			let exposedPorts: [Entry] = self.exposedPorts?
				.compactMap {
					guard let entry = Entry(exposedPort: $0.key) else { return nil }
					guard !mappedPorts.contains(entry.containerPort) else { return nil }

					mappedPorts.insert(entry.containerPort)
					return entry
				} ?? []

			let portBindings: [Entry] = self.portBindings?
				.compactMap { portBinding in
					portBinding.value.compactMap {
						guard let entry = Entry(portBinding: $0, portBindingString: portBinding.key) else { return nil }
						guard !mappedPorts.contains(entry.containerPort) else { return nil }

						mappedPorts.insert(entry.containerPort)
						return entry
					}
				}
				.flatMap { $0 } ?? []

			return (ports + exposedPorts + portBindings)
				.sorted { ($0.containerPort, $0.hostPort ?? 0, $0.portType ?? "") < ($1.containerPort, $1.hostPort ?? 0, $1.portType ?? "") }
		}

		var body: some View {
			if !entries.isEmpty {
				NormalizedSection {
					ForEach(entries, id: \.hashValue) { entry in
						// haha it works
						let shareMenu = {
							Group {
								if let publicPort = entry.publicPort {
									CopyButton("ContainerDetailsView.NetworkDetailsView.CopyIP", content: entry.hostLabel)

									if let endpointPublicURL = portainerStore.selectedEndpoint?.publicURL {
										Divider()

//										CopyButton("ContainerDetailsView.NetworkDetailsView.CopyPublicURL", content: "\(endpointPublicURL):\(publicPort)")
//
//										if let portURL = URL(string: "http://\(endpointPublicURL):\(publicPort)") {
//											Link(destination: portURL) {
//												Label("ContainerDetailsView.NetworkDetailsView.OpenPublicURL", systemImage: SFSymbol.web)
//											}
//										}

										let portURLString = "http://\(endpointPublicURL):\(publicPort)"
										if let portURL = URL(string: portURLString) {
											ShareLink("ContainerDetailsView.NetworkDetailsView.SharePublicURL", item: portURL)
										} else {
											ShareLink("ContainerDetailsView.NetworkDetailsView.SharePublicURL", item: portURLString)
										}
									}
								}
							}
							.labelStyle(.titleAndIcon)
						}

						LabeledContent(entry.containerLabel) {
							HStack {
								if let hostLabel = entry.hostLabel {
									Text(hostLabel)

									#if os(macOS)
									if entry.publicPort != nil {
										Menu {
											shareMenu()
										} label: {
											Label("Generic.More", systemImage: SFSymbol.more)
												.hidden()
										}
										.menuStyle(.button)
										.buttonStyle(.borderless)
										.fixedSize(horizontal: true, vertical: false)
									}
									#endif
								}
							}
						}
						.fontDesign(.monospaced)
						#if os(iOS)
						.contextMenu {
							shareMenu()
						}
						#elseif os(macOS)
						.textSelection(.enabled)
						#endif
					}
				} header: {
					Text("ContainerDetailsView.NetworkDetailsView.Ports")
				}
			}
		}
	}
}

private extension ContainerDetailsView.NetworkDetailsView.PortsSection {
	struct Entry: Hashable {
		let containerPort: Int

		let hostIP: String?
		let hostPort: Int?

		let portType: String?

		let publicPort: Int?

		var containerLabel: String {
			if let portType {
				"\(containerPort)/\(portType)"
			} else {
				"\(containerPort)"
			}
		}

		var hostLabel: String? {
			guard let hostPort else { return nil }
			return "\(hostIP ?? "0.0.0.0"):\(hostPort)"
		}

		init?(port: PortainerKit.Port) {
			if let privatePort = port.privatePort {
				self.containerPort = Int(privatePort)
			} else {
				return nil
			}

			self.hostIP = port.ip

			if let publicPort = port.publicPort {
				let hostPortInt = Int(publicPort)
				self.hostPort = hostPortInt
				self.publicPort = hostPortInt
			} else {
				self.hostPort = nil
				self.publicPort = nil
			}

			self.portType = port.type?.rawValue
		}

		init?(exposedPort: String) {
			// 8080/tcp
			let exposedPortSplit = exposedPort.split(separator: "/")
			let (portStr, portType) = (exposedPortSplit[safe: 0], exposedPortSplit[safe: 1])

			guard let portStr, let port = Int(portStr) else { return nil }
			self.containerPort = port

			self.hostIP = nil
			self.hostPort = port

			if let portType {
				self.portType = String(portType)
			} else {
				self.portType = nil
			}

			self.publicPort = port
		}

		init?(portBinding: ContainerDetails.HostConfig.PortBinding, portBindingString: String) {
			// 8080/tcp
			let portBindingStringSplit = portBindingString.split(separator: "/")
			let (portStr, portType) = (portBindingStringSplit[safe: 0], portBindingStringSplit[safe: 1])

			if let portStr, let port = Int(portStr) {
				self.containerPort = port
			} else {
				return nil
			}

			self.hostIP = nil

			if let hostPort = portBinding.hostPort {
				let hostPortInt = Int(hostPort.filter { $0.isNumber })
				self.hostPort = hostPortInt
				self.publicPort = hostPortInt
			} else {
				self.hostPort = nil
				self.publicPort = nil
			}

			if let portType {
				self.portType = String(portType)
			} else {
				self.portType = nil
			}
		}
	}
}

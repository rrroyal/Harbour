//
//  ContainerMountsDetailsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerMountsDetailsView: View {
	let mounts: [PortainerKit.Mount]?
	let details: [PortainerKit.MountPoint]?
	
	@ViewBuilder
	var emptyDisclaimer: some View {
		if mounts?.isEmpty ?? true && details?.isEmpty ?? true {
			Text("No mounts")
				.opacity(Globals.Views.secondaryOpacity)
		}
	}
	
	@ViewBuilder
	var generalSection: some View {
		ForEach(mounts?.sorted(by: { ($0.source ?? "", $0.target ?? "") > ($1.source ?? "", $1.target ?? "") }) ?? [], id: \.self) { mount in
			Section {
				Group {
					Labeled(label: "Source", content: mount.source, monospace: true)
					Labeled(label: "Target", content: mount.target, monospace: true)
					Labeled(label: "Read only?", bool: mount.readOnly)
					Labeled(label: "Type", content: mount.type?.rawValue, monospace: true)
					Labeled(label: "Consistency", content: mount.consistency?.rawValue, monospace: true)
					Labeled(label: "Bind options", content: mount.bindOptions?.propagation?.rawValue, monospace: true)
				}
				
				Group {
					VolumeOptionsSection(volumeOptions: mount.volumeOptions)
					TmpfsOptionsSection(tmpfsOptions: mount.tmpfsOptions)
				}
			}
		}
	}
	
	@ViewBuilder
	var detailSection: some View {
		if let details = details {
			ForEach(details.sorted(by: { $0.destination > $1.destination }), id: \.self) { mount in
				Section(mount.destination) {
					Labeled(label: "Name", content: mount.name, monospace: true)
					Labeled(label: "Source", content: mount.source, monospace: true)
					Labeled(label: "Destination", content: mount.destination, monospace: true)

					Labeled(label: "Driver", content: mount.driver, monospace: true)
					Labeled(label: "Mode", content: mount.mode, monospace: true)
					Labeled(label: "Type", content: mount.type, monospace: true)
					Labeled(label: "Propagation", content: mount.propagation, monospace: true)
					Labeled(label: "RW?", bool: mount.rw)
				}
			}
		}
	}
	
	var body: some View {
		List {
			generalSection
			detailSection
		}
		.overlay(emptyDisclaimer)
		.navigationTitle("Mounts")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarTitle(title: "Mounts", subtitle: nil)
		}
	}
}

fileprivate extension ContainerMountsDetailsView {
	struct VolumeOptionsSection: View {
		let volumeOptions: PortainerKit.VolumeOptions?
		
		var body: some View {
			if let volumeOptions = volumeOptions {
				DisclosureGroup("Volume options") {
					Labeled(label: "No copy?", bool: volumeOptions.noCopy)
					
					if let labels = volumeOptions.labels, !labels.isEmpty {
						DisclosureGroup("Labels") {
							ForEach(labels.sorted(by: >), id: \.key) { key, value in
								Labeled(label: key, content: value, monospace: true)
							}
						}
					} else {
						Labeled(label: "Labels", content: nil, monospace: true)
					}
					
					if let driverConfig = volumeOptions.driverConfig {
						DisclosureGroup("Driver config") {
							Labeled(label: "Name", content: driverConfig.name, monospace: true)
							
							if let options = driverConfig.options, !options.isEmpty {
								DisclosureGroup("Options") {
									ForEach(options.sorted(by: >), id: \.key) { key, value in
										Labeled(label: key, content: value, monospace: true)
									}
								}
							} else {
								Labeled(label: "Options", content: nil, monospace: true)
							}
						}
					} else {
						Labeled(label: "Driver config", content: nil, monospace: true)
					}
				}
			} else {
				Labeled(label: "Volume options", content: nil, monospace: true)
			}
		}
	}
	
	struct TmpfsOptionsSection: View {
		let tmpfsOptions: PortainerKit.TmpfsOptions?
		
		var body: some View {
			if let tmpfsOptions = tmpfsOptions {
				DisclosureGroup("tmpfs options") {
					Labeled(label: "Mode", content: tmpfsOptions.mode != nil ? "\(tmpfsOptions.mode ?? 0)" : nil, monospace: true)
					Labeled(label: "Size (B)", content: tmpfsOptions.sizeBytes != nil ? "\(tmpfsOptions.sizeBytes ?? 0)" : nil, monospace: true)
				}
			} else {
				Labeled(label: "tmpfs options", content: nil, monospace: true)
			}
		}
	}
}

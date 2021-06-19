//
//  ContainerMountsDetailsView.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import PortainerKit
import SwiftUI

struct ContainerMountsDetailsView: View {
	let container: PortainerKit.Container
	
	var body: some View {
		List {
			ForEach(container.mounts ?? [], id: \.target) { mount in
				MountSection(mount: mount)
			}
		}
		.navigationTitle("Mounts")
	}
}

private extension ContainerMountsDetailsView {
	struct MountSection: View {
		let mount: PortainerKit.Mount
		
		var generalSection: some View {
			Group {
				MonospaceLabeled(label: "Target", content: mount.target)
				MonospaceLabeled(label: "Source", content: mount.source)
				MonospaceLabeled(label: "Type", content: mount.type?.rawValue)
				MonospaceLabeled(label: "Read only", content: mount.readOnly != nil ? "\(mount.readOnly ?? false)" : nil)
			}
		}
		
		@ViewBuilder
		var consistencySection: some View {
			if let consistency = mount.consistency {
				DisclosureGroup("Consistency") {}
			} else {
				MonospaceLabeled(label: "Consistency", content: nil)
			}
		}
		
		@ViewBuilder
		var bindOptionsSection: some View {
			if let options = mount.bindOptions {
				DisclosureGroup("Bind options") {}
			} else {
				MonospaceLabeled(label: "Bind options", content: nil)
			}
		}
		
		@ViewBuilder
		var volumeOptionsSection: some View {
			if let options = mount.volumeOptions {
				DisclosureGroup("Volume options") {}
			} else {
				MonospaceLabeled(label: "Volume options", content: nil)
			}
		}
		
		@ViewBuilder
		var tmpfsOptionsSection: some View {
			if let options = mount.tmpfsOptions {
				DisclosureGroup("tmpfs options") {
					MonospaceLabeled(label: "Size bytes", content: options.sizeBytes != nil ? "\(options.sizeBytes ?? -1)" : nil)
					MonospaceLabeled(label: "Mode", content: options.mode != nil ? "\(options.mode ?? -1)" : nil)
				}
			} else {
				MonospaceLabeled(label: "tmpfs options", content: nil)
			}
		}
		
		var body: some View {
			Section {
				generalSection
				consistencySection
				bindOptionsSection
				volumeOptionsSection
				tmpfsOptionsSection
			}
		}
	}
}

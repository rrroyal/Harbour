//
//  ContainerDetailsView+DevicesDetailsView.swift
//  Harbour
//
//  Created by enzofrnt on 16/10/2025.
//  Copyright © 2025 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

extension ContainerDetailsView {
    struct DevicesDetailsView: View {
        let devices: [Device]?

        private var data: [KeyValueEntry] {
            (devices ?? [])
                .map { device in
                    let key = device.pathOnHost ?? ""
                    let valueBase = device.pathInContainer ?? ""
                    let value: String
                    value = valueBase
                    return KeyValueEntry(key: key, value: value)
                }
        }

        var body: some View {
            KeyValueListView(data: data)
                .headerFontDesign(.monospaced)
                .contentFontDesign(.monospaced)
                .navigationTitle("ContainerDetailsView.Section.Devices")
        }
    }
}


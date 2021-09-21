//
//  DebugView.swift
//  Harbour
//
//  Created by unitears on 19/06/2021.
//

import SwiftUI

struct DebugView: View {
    var body: some View {
		List {
			Section(header: Text("UserDefaults")) {
				Button("Reset launchedBefore") {
					Preferences.shared.launchedBefore = false
				}
				
				Button("Reset all") {
					Preferences.Key.allCases.forEach { Preferences.shared.ud.removeObject(forKey: $0.rawValue) }
					exit(0)
				}
				.accentColor(.red)
			}
		}
		.navigationTitle("🤫")
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}

//
//  DetailLabel.swift
//  Harbour
//
//  Created by royal on 06/04/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct DetailLabel: View {
	var title: String
	var value: String
	var monospaced: Bool?
	
	var body: some View {
		VStack(alignment: .leading) {
			// Title
			Text(LocalizedStringKey(title))
				.font(.headline)
				.padding(.bottom, 2)
			
			// Value
			Text(LocalizedStringKey(value.trimmingCharacters(in: .whitespacesAndNewlines)))
				.font(.system(.body, design: (monospaced ?? false) ? .monospaced : .default))
		}
		.padding(.bottom, 10)
		.multilineTextAlignment(.leading)
		.lineLimit(nil)
		.onTapGesture {
			generateHaptic(.light)
			UIPasteboard.general.string = self.value
			print("[!] Copied value: \"\(self.value)\"")
		}
	}
}

struct DetailLabel_Previews: PreviewProvider {
    static var previews: some View {
		DetailLabel(title: "Title", value: "Value")
    }
}

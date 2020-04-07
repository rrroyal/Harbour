//
//  ListCellLabel.swift
//  Harbour
//
//  Created by royal on 06/04/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct ListCellLabel: View {
	@State var title: String
	@State var value: String
	var canCopy: Bool? = false
	
	var body: some View {
		VStack(alignment: .leading) {
			// Title
			Text(LocalizedStringKey(title))
				.font(.headline)
				.padding(.bottom, 1)
			
			// Value
			Text(LocalizedStringKey(value.trimmingCharacters(in: .whitespacesAndNewlines)))
				.font(.system(.callout, design: .monospaced))
				.multilineTextAlignment(.leading)
				.lineLimit(nil)
				.onTapGesture {
					if (!(self.canCopy ?? false)) { return }
					
					generateHaptic(.light)
					UIPasteboard.general.string = self.value
					print("[!] Copied value: \"\(self.value)\"")
				}
		}
		.padding(2)
		// .id("containerDetailCellLabel:\(label):\(value)")
		// .animation(.easeInOut)
		// .transition(.opacity)
	}
}

/* struct ListCellLabel_Previews: PreviewProvider {
    static var previews: some View {
        ListCellLabel()
    }
} */

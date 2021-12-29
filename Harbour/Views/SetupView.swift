//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 19/06/2021.
//

import SwiftUI

struct SetupView: View {
	@State private var selection: Int = 0
	
    var body: some View {
		TabView(selection: $selection) {
			WelcomeView(selection: $selection)
				.tag(0)
			
			if !Portainer.shared.isReady {
				LoginView()
					.environmentObject(Portainer.shared)
					.tag(1)
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
    }
}

fileprivate struct WelcomeView: View {
	@Environment(\.presentationMode) var presentationMode
	@Binding var selection: Int
	
	var body: some View {
		VStack {
			Spacer()
			
			Text("Hi! Welcome to \(Text("Harbour").foregroundColor(.accentColor))!")
				.font(.largeTitle.bold())
				.multilineTextAlignment(.center)
			
			Spacer()
			
			VStack(spacing: 20) {
				FeatureCell(image: "power", headline: Localization.SETUP_FEATURE1_TITLE.localized, description: Localization.SETUP_FEATURE1_DESCRIPTION.localized)
				FeatureCell(image: "doc.plaintext", headline: Localization.SETUP_FEATURE2_TITLE.localized, description: Localization.SETUP_FEATURE2_DESCRIPTION.localized)
				FeatureCell(image: "terminal", headline: Localization.SETUP_FEATURE3_TITLE.localized, description: Localization.SETUP_FEATURE3_DESCRIPTION.localized)
			}
			
			Spacer()
			
			Button("Beam me up, Scotty!") {
				UIDevice.generateHaptic(.soft)
				if Portainer.shared.isReady {
					presentationMode.wrappedValue.dismiss()
				} else {
					withAnimation { selection = 1 }
				}
			}
			.buttonStyle(.customPrimary)
		}
		.padding()
	}
}

fileprivate extension WelcomeView {
	struct FeatureCell: View {
		let image: String
		let headline: String
		let description: String
		
		let imageWidth: Double = 60
		
		var body: some View {
			HStack(spacing: 10) {
				Image(systemName: image)
					.font(.title.weight(.semibold))
					.foregroundStyle(Color.accentColor)
					.symbolVariant(.fill)
					.symbolRenderingMode(.hierarchical)
					.frame(width: imageWidth)
				
				VStack(alignment: .leading, spacing: 2) {
					Text(LocalizedStringKey(headline))
						.font(.headline)
						.frame(maxWidth: .infinity, alignment: .leading)
					
					Text(LocalizedStringKey(description))
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
	}
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}

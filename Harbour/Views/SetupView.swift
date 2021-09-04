//
//  SetupView.swift
//  Harbour
//
//  Created by unitears on 19/06/2021.
//

import SwiftUI

struct SetupView: View {
	@State private var selection: Int = 0
	
    var body: some View {
		TabView(selection: $selection) {
			WelcomeView(selection: $selection)
				.tag(0)
			
			if !Portainer.shared.isLoggedIn {
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
				FeatureCell(image: "power", headline: "%SETUP_FEATURE1_HEADLINE%", description: "%SETUP_FEATURE1_DESCRIPTION%")
				FeatureCell(image: "square.text.square", headline: "%SETUP_FEATURE2_HEADLINE%", description: "%SETUP_FEATURE2_DESCRIPTION%")
				FeatureCell(image: "terminal", headline: "%SETUP_FEATURE3_HEADLINE%", description: "%SETUP_FEATURE3_DESCRIPTION%")
			}
			
			Spacer()
			
			Button("Beam me up, Scotty!") {
				UIDevice.current.generateHaptic(.soft)
				if Portainer.shared.isLoggedIn {
					presentationMode.wrappedValue.dismiss()
				} else {
					withAnimation { selection = 1 }
				}
			}
			.buttonStyle(PrimaryButtonStyle())
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

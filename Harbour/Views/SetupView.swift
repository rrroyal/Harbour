//
//  SetupView.swift
//  Harbour
//
//  Created by royal on 19/06/2021.
//

import SwiftUI

struct SetupView: View {
	@State private var presentedView: PresentedView = .welcome
	
    var body: some View {
		TabView(selection: $presentedView) {
			WelcomeView(presentedView: $presentedView)
				.tag(PresentedView.welcome)
			
			if !(Portainer.shared.isReady && Portainer.shared.hasSavedCredentials) {
				LoginView()
					.environmentObject(Portainer.shared)
					.tag(PresentedView.setup)
			}
		}
		.tabViewStyle(.page(indexDisplayMode: .never))
    }
}

extension SetupView {
	enum PresentedView {
		case welcome, setup
	}
	
	struct WelcomeView: View {
		@Environment(\.presentationMode) var presentationMode
		@Binding var presentedView: PresentedView
		
		var body: some View {
			VStack {
				Spacer()
				
				Text("Hi! Welcome to \(Text("Harbour").foregroundColor(.accentColor))!")
					.font(.largeTitle.bold())
					.multilineTextAlignment(.center)
				
				Spacer()
				
				VStack(spacing: 20) {
					FeatureCell(image: "power", headline: Localization.Setup.Feature1.title, description: Localization.Setup.Feature1.description)
					FeatureCell(image: "doc.plaintext", headline: Localization.Setup.Feature2.title, description: Localization.Setup.Feature2.description)
					FeatureCell(image: "terminal", headline: Localization.Setup.Feature3.title, description: Localization.Setup.Feature3.description)
				}
				
				Spacer()
				
				Button("Beam me up, Scotty!") {
					UIDevice.generateHaptic(.soft)
					if Portainer.shared.isReady {
						presentationMode.wrappedValue.dismiss()
					} else {
						withAnimation { presentedView = .setup }
					}
				}
				.buttonStyle(.customPrimary)
			}
			.padding()
		}
	}
}

private extension SetupView.WelcomeView {
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

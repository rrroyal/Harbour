//
//  UI.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

/// Modifies button to our custom style
struct ButtonModifier: ViewModifier {
	var style: Color
	
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(style))
            .padding(.bottom)
    }
}

extension View {
	func customButton(_ style: Color) -> ModifiedContent<Self, ButtonModifier> {
		return modifier(ButtonModifier(style: style))
    }
	
	public func dynamicNavigationViewStyle(useFullscreen: Bool) -> AnyView {
        if useFullscreen {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self.navigationViewStyle(DefaultNavigationViewStyle()))
        }
    }
}

extension Text {
    func customTitleText() -> Text {
        self
            .fontWeight(.bold)
            .font(.system(size: 32))
    }

}

extension Color {
	static var mainColor: Color = Color("mainColor")
	static var cellBackground: Color = Color("cellBackground")
}

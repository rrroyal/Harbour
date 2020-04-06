//
//  AdaptsToSoftwareKeyboard.swift
//  Harbour
//
//  Created by royal on 22/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI
import Combine

struct AdaptsToSoftwareKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0
  
    func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight)
			// .animation(.easeInOut(duration: 0.25))
			.animation(.default)
            .edgesIgnoringSafeArea(currentHeight == 0 ? Edge.Set() : .bottom)
            .onAppear(perform: subscribeToKeyboardChanges)
    }
  
    // MARK: - Keyboard Height
    private let keyboardHeightOnOpening = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height }
  
    private let keyboardHeightOnHiding = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in return CGFloat(0) }
      
    // MARK: - Subscriber to Keyboard's changes
    private func subscribeToKeyboardChanges() {
        _ = Publishers.Merge(keyboardHeightOnOpening, keyboardHeightOnHiding)
            .subscribe(on: RunLoop.main)
            .sink { height in
                if self.currentHeight == 0 || height == 0 {
                    self.currentHeight = height
                }
			}
    }
}

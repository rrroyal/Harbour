//
//  DrawerView.swift
//  Harbour
//
//  Created by royal on 28/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

struct DrawerView<Content: View>: View {
    @Binding var isExpanded: Bool
    @State private var translation = CGSize.zero
    var content: Content
	
	// Animation style
	let drawerAnimation: Animation = Animation.interpolatingSpring(mass: 0.5, stiffness: 45, damping: 45, initialVelocity: 15)
    
    // The default opacity of back layer when the drawer is pulled out
	let backgroundExpandedOpacity: CGFloat = 0 // 0.1
    var backgroundOpacity: Double {
        if self.translation.height < 0 {
			return isExpanded ? Double(backgroundExpandedOpacity) : Double(min(abs(self.translation.height * 0.001), backgroundExpandedOpacity))
        } else {
            return isExpanded ? Double(max(backgroundExpandedOpacity - abs(self.translation.height * 0.001), 0)) : 0
        }
    }
	
	// Drawer shadow
	var isDrawerShadowEnabled = true
    
	// Drawer size
	var expectedDrawerHeight: CGFloat?
    private var drawerHeight: CGFloat {
		if let height = expectedDrawerHeight {
			return height
		}
		
		if (UIDevice.current.userInterfaceIdiom == .pad && DeviceInfo.Orientation.isPortrait) {
			return UIScreen.main.bounds.height / 2.4
		}
		
        return UIScreen.main.bounds.height / 2
    }
    
	private var drawerWidth: CGFloat {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return UIScreen.main.bounds.width
		} else {
			return 400
		}
	}
    
	// Drawer position
	private var xOffset: CGFloat {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return 0
		} else {
			if (SettingsModel().useFullScreenDashboard) {
				return (UIScreen.main.bounds.width - drawerWidth) / 2.2
			} else {
				if (DeviceInfo.Orientation.isLandscape) {
					return (UIScreen.main.bounds.width - drawerWidth) / 4
				} else if (DeviceInfo.Orientation.isPortrait) {
					return (UIScreen.main.bounds.width - drawerWidth) / 2.1
				} else {
					return 0
				}
			}
		}
	}
    
    private var initYOffset: CGFloat? {
		let screenFactor: CGFloat = UIScreen.main.bounds.height < 700 ? 30 : 0
		let drawerSizeShrinkedFactor: CGFloat = UIDevice.current.userInterfaceIdiom == .pad && DeviceInfo.Orientation.isPortrait ? 1.5 : 1.78
		let drawerSize: CGFloat = isExpanded ? ((UIScreen.main.bounds.height - drawerHeight) * 1.25) : ((UIScreen.main.bounds.height + drawerHeight) / drawerSizeShrinkedFactor)
				
		/* if (UIDevice.current.userInterfaceIdiom == .pad) {
			return drawerSize - screenFactor + 70
		} */
		
		return drawerSize - screenFactor
    }
    
    private var yOffset: CGFloat {
		if ((isExpanded && translation.height < 0) || (!isExpanded && translation.height > 0)) {
			if let y = initYOffset {
				return y + (translation.height * 0.075)
			}
		}
		
        if let y = initYOffset {
            return y + translation.height
        }
        return 0
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Darken the background
            Rectangle()
				.background(Color.black)
				.opacity(self.backgroundOpacity)
				.animation(drawerAnimation)
                .transition(.opacity)
				.contentShape(Rectangle())
				.allowsHitTesting(self.isExpanded)
				.layoutPriority(10)
                .onTapGesture {
                    self.isExpanded = false
                }

            // Drawer
            VStack {
                // Title
                VStack {
                    Image(systemName: self.isExpanded ? "chevron.compact.down" : "minus")
                        .font(.system(size: 32, weight: .semibold, design: .default))
                        .opacity(0.2)
                        .transition(.opacity)
                        .animation(.easeInOut)
                        .id(self.isExpanded ? "expandedIndicator" : "notExpandedIndicator")
                        .padding(.top)
                    Spacer()
                }
                .frame(width: drawerWidth, height: 25)
                .background(Color(UIColor.secondarySystemBackground))
				.onTapGesture {
					self.isExpanded.toggle()
				}
                
                // Drawer content
                content
					.padding()
				
				// Spacer()
            }
            .frame(
                width: drawerWidth,
                height: UIScreen.main.bounds.height
            )
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
            .gesture(
                DragGesture()
                    .onChanged { (value) in
                        self.translation = value.translation
                    }
                    .onEnded { (value) in
						if (value.translation.height > 20 && self.isExpanded) {
							// Hide
							self.isExpanded.toggle()
						} else if (value.translation.height < -20 && !self.isExpanded) {
							// Open
							self.isExpanded.toggle()
						}
                        self.translation = CGSize.zero
                    }
            )
			.shadow(color: Color.black.opacity(0.15), radius: isDrawerShadowEnabled ? 16 : 0, x: 0, y: 0)
            .offset(x: xOffset, y: yOffset)
            .animation(drawerAnimation)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


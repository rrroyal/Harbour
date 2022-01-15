//
//  SelectedRoundedRectangle.swift
//  Harbour
//
//  Created by royal on 11/01/2022.
//

import SwiftUI

struct SelectedRoundedRectangle: Shape {
	let radius: CGFloat
	let corners: UIRectCorner
	
	public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
		self.radius = radius
		self.corners = corners
	}
	
	func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}

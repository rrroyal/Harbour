//
//  CollectionView.swift
//  Harbour
//
//  Created by royal on 24/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

public struct CollectionView<Data, Content>: View where Data: RandomAccessCollection, Content: View, Data.Element: Identifiable {
	private struct Index: Identifiable {
		var id: Int
	}
    
	private let isFullScreen: Bool
	private let columns: Int
	private let columnsInLandscape: Int
	private let vSpacing: CGFloat = 10
	private let hSpacing: CGFloat = 10
	private let vPadding: CGFloat = 0
	private let hPadding: CGFloat = 5
  
	private let data: [Data.Element]
	private let content: (Data.Element) -> Content
  
	public init(_ data: Data, isFullScreen: Bool? = false, content: @escaping (Data.Element) -> Content) {
		self.data = data.map { $0 }
		self.content = content
		self.isFullScreen = isFullScreen ?? false
		self.columns = UIDevice.current.userInterfaceIdiom == .phone ? 3 : (isFullScreen ?? false) ? 5 : 2
		self.columnsInLandscape = (isFullScreen ?? false) ? 7 : 2
	}
    
	private var rows: Int {
		data.count / self.cols
	}
  
	private var cols: Int {
		#if os(macOS)
		return columnsInLandscape
		#else
		return DeviceInfo.Orientation.isLandscape ? columnsInLandscape : columns
		#endif
  }
  
	public var body : some View {
		GeometryReader { geometry in
			ScrollView(showsIndicators: false) {
				VStack(spacing: self.vSpacing) {
					ForEach((0 ..< self.rows).map { Index(id: $0) }) { row in
						self.rowAtIndex(row.id * self.cols, geometry: geometry)
					}
          
					// Last row
					if ((self.data.count % self.cols) > 0) {
						self.rowAtIndex(self.cols * self.rows, geometry: geometry, isLastRow: true)
					}
				}
			}
			.padding(.horizontal, self.hPadding)
			.padding(.vertical, self.vPadding)
		}
	}
    
	private func rowAtIndex(_ index: Int, geometry: GeometryProxy, isLastRow: Bool = false) -> some View {
		HStack(spacing: self.hSpacing) {
			ForEach((0 ..< (isLastRow ? data.count % cols : cols))
				.map { Index(id: $0) }) { column in
					self.content(self.data[index + column.id])
						.frame(width: self.contentWidthFor(geometry))
				}
			
			if (isLastRow) {
				Spacer()
			}
		}
	}

	private func contentWidthFor(_ geometry: GeometryProxy) -> CGFloat {
		let hSpacings = hSpacing * (CGFloat(self.cols) - 1)
		let width = geometry.size.width - hSpacings - hPadding * 2
		return width / CGFloat(self.cols)
	}
}

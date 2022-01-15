//
//  ContainersGridView.swift
//  Harbour
//
//  Created by royal on 04/10/2021.
//

import SwiftUI
import PortainerKit

#warning("TODO: Unnecessary environment updates")
#warning("TODO: GridCells are not removed (reference cycle?)")

struct ContainersGridView: View {
	@EnvironmentObject var portainer: Portainer
	@EnvironmentObject var sceneState: SceneState
	let containers: [ContainersView.ContainersStack]
	
	static let padding: Double = 10
			
	var body: some View {
		Self._printChanges()
		return ScrollView {
			GridView(containers: containers)
				.equatable()
		}
		.transition(.opacity)
		.animation(.easeInOut, value: containers.count)
	}
}

extension ContainersGridView: Equatable {
	static func == (lhs: ContainersGridView, rhs: ContainersGridView) -> Bool {
		lhs.containers == rhs.containers
	}
}

private extension ContainersGridView {
	struct GridView: View {
		@EnvironmentObject var portainer: Portainer
		@EnvironmentObject var sceneState: SceneState
		@Environment(\.horizontalSizeClass) var horizontalSizeClass
		let containers: [PortainerKit.Container]
		
		internal init(containers: [ContainersView.ContainersStack]) {
			self.containers = containers.flatMap(\.containers)
		}

		private var columns: Int {
			horizontalSizeClass == .regular ? 6 : 3
		}
		
		private var containersEnumerated: [(index: Int, container: PortainerKit.Container)] {
			containers.enumerated().map { (index: $0, container: $1) }
		}
		
		#warning("TODO: Move this to ViewController or something so that it's not recomputed on every access but only on changes")
		private var gridCells: [GridCell] {
			// Map containers to GridCells
			let cells: [GridCell] = containers.enumerated()
				.map { GridCell(stack: $1.stack, index: $0, line: $0 / columns, position: .init(index: $0, columns: columns)) }
			
			// Map relative positions
			let mapped: [GridCell] = cells.map { cell in
				let previousI = cell.index - 1
				cell.previous = previousI >= cells.startIndex ? cells[previousI] : nil
				
				let aboveI = cell.index - columns
				cell.above = aboveI >= cells.startIndex ? cells[aboveI] : nil
				
				let nextI = cell.index + 1
				cell.next = nextI < cells.endIndex ? cells[nextI] : nil
				
				let belowI = cell.index + columns
				cell.below = belowI < cells.endIndex ? cells[belowI] : nil
				
				let sameLine = cells.filter { $0.line == cell.line }
				cell.firstInLineConnectedBelow = sameLine.first(where: { $0.stack == cell.stack && $0.below?.stack == cell.stack })
				cell.firstInLineConnectedAbove = sameLine.first(where: { $0.stack == cell.stack && $0.above?.stack == cell.stack })
				
				cell.update()
				return cell
			}
			
			return mapped
		}
		
		var body: some View {
			Self._printChanges()
			return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columns), spacing: 0) {
				ForEach(containersEnumerated, id: \.container.id) { pair in
					NavigationLink(tag: pair.container.id, selection: $sceneState.activeContainerID, destination: {
						ContainerDetailView(container: pair.container)
							.equatable()
							.environmentObject(sceneState)
							.environmentObject(portainer)
					}) {
						ContainerCell(container: pair.container)
							.equatable()
							.contextMenu { ContainerContextMenu(container: pair.container) }
							.onDrag { ContainersView.containerDragProvider(container: pair.container) }
					}
					.buttonStyle(.decreasesOnPress)
					.modifier(StackBackgroundModifier(gridCell: gridCells[pair.index]))
				}
			}
		}
	}
	
	private struct StackBackgroundModifier: ViewModifier {
		let stack: String?
		let paddingFilled: Edge.Set?
		let paddingUnfilled: Edge.Set?
		let roundedCorners: UIRectCorner?
				
		internal init(gridCell: GridView.GridCell) {
			self.stack = gridCell.stack
			self.paddingFilled = gridCell.paddingFilled
			self.paddingUnfilled = gridCell.paddingUnfilled
			self.roundedCorners = gridCell.roundedCorners
			gridCell.cleanup()
		}
		
		func body(content: Content) -> some View {
			if stack != nil {
				content
					.padding(paddingFilled ?? [], padding)
					.background(SelectedRoundedRectangle(radius: Constants.largeCornerRadius, corners: roundedCorners ?? []).fill(ContainersView.stackBackground))
					.padding(paddingUnfilled ?? [], padding)
			} else {
				content
					.padding(paddingUnfilled ?? [], padding)
			}
		}
	}
}

extension ContainersGridView.GridView: Equatable {
	static func == (lhs: ContainersGridView.GridView, rhs: ContainersGridView.GridView) -> Bool {
		lhs.containers == rhs.containers
	}
	
	final class GridCell: Equatable, Identifiable {
		let stack: String?
		let index: Int
		let line: Int
		let position: GridPosition
		var paddingFilled: Edge.Set? = nil
		var paddingUnfilled: Edge.Set? = nil
		var roundedCorners: UIRectCorner? = nil
		
		weak var previous: GridCell? = nil
		weak var next: GridCell? = nil
		weak var above: GridCell? = nil
		weak var below: GridCell? = nil
		
		weak var firstInLineConnectedBelow: GridCell? = nil
		weak var firstInLineConnectedAbove: GridCell? = nil
		
		var connectedLeading: Bool = false
		var connectedTrailing: Bool = false
		var connectedTop: Bool = false
		var connectedBottom: Bool = false
		
		var id: String { "\(line)-\(index)-\(stack ?? "")" }
		
		internal init(stack: String?, index: Int, line: Int, position: GridPosition) {
			self.stack = stack
			self.index = index
			self.line = line
			self.position = position
		}
		
		public func update() {
			updatePaddings()
			updateRoundedCorners()
		}
		
		public func cleanup() {
			previous = nil
			above = nil
			next = nil
			below = nil
			firstInLineConnectedAbove = nil
			firstInLineConnectedBelow = nil
		}
		
		private func updatePaddings() {
			var filled: Edge.Set = []
			let allEdges: Edge.Set = [.leading, .trailing, .top, .bottom]
			
			if let stack = stack {
				let leadingConnected = previous?.stack == stack
				let trailingConnected = next?.stack == stack
				let topConnected = above?.stack == stack
				let bottomConnected = below?.stack == stack
				
				if leadingConnected {
					/// - Previous is same (✅)
					/// - If leading:
					/// 	- Not connected above
					/// 	- Not connected below
					/// 	- Other cell connects above
					if position == .leading {
						if !topConnected && !bottomConnected && previous?.firstInLineConnectedBelow == nil {
							connectedLeading = true
						}
					} else {
						connectedLeading = true
					}
				}
				
				if trailingConnected {
					/// - Next is same (✅)
					/// - If trailing:
					/// 	- Not connected above
					/// 	- Not connected below
					/// 	- Other cell connects below
					if position == .trailing {
						if !topConnected && !bottomConnected && firstInLineConnectedBelow == nil {
							connectedTrailing = true
						}
					} else {
						connectedTrailing = true
					}
				}
				
				if topConnected {
					/// - Above is same (✅)
					connectedTop = true
				}
				
				if bottomConnected {
					/// - Below is same (✅)
					connectedBottom = true
				}
			}
			
			if connectedLeading { filled.update(with: .leading) }
			if connectedTrailing { filled.update(with: .trailing) }
			if connectedTop { filled.update(with: .top) }
			if connectedBottom { filled.update(with: .bottom) }
			
			self.paddingFilled = filled
			self.paddingUnfilled = allEdges.subtracting(filled)
		}
		
		private func updateRoundedCorners() {
			var roundedCorners: UIRectCorner = []
			
			if !connectedLeading {
				roundedCorners.insert(.topLeft)
				roundedCorners.insert(.bottomLeft)
			}
			
			if !connectedTrailing {
				roundedCorners.insert(.topRight)
				roundedCorners.insert(.bottomRight)
			}
			
			if connectedTop {
				roundedCorners.remove(.topLeft)
				roundedCorners.remove(.topRight)
			}
			
			if connectedBottom {
				roundedCorners.remove(.bottomLeft)
				roundedCorners.remove(.bottomRight)
			}
			
			self.roundedCorners = roundedCorners
		}
		
		static func == (lhs: ContainersGridView.GridView.GridCell, rhs: ContainersGridView.GridView.GridCell) -> Bool {
			lhs.id == rhs.id
		}
		
		enum GridPosition: Int {
			case leading = 0, other, trailing
			
			init(index: Int, columns: Int) {
				if index % columns == 0 {
					self = .leading
				} else if (index + 1) % columns == 0 {
					self = .trailing
				} else {
					self = .other
				}
			}
		}
	}
}

struct ContainersGridView_Previews: PreviewProvider {
    static var previews: some View {
		ContainersGridView(containers: [])
    }
}

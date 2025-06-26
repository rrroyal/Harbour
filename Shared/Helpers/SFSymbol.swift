//
//  SFSymbol.swift
//  Harbour
//
//  Created by royal on 11/08/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation

// MARK: - SFSymbol

enum SFSymbol {
	/// 􀆅 checkmark
	static let apply = "checkmark"

	/// 􀅀 arrow.down.to.line
	static let arrowDownLine = "arrow.down.to.line"

	/// 􀄿 arrow.up.to.line
	static let arrowUpLine = "arrow.up.to.line"

	/// 􀆄 xmark
	static let cancel = "xmark"

	/// 􀯶 chevron.backward
	static let chevronBackward = "chevron.backward"

	/// 􀆈 chevron.down
	static let chevronDown = "chevron.down"

	/// 􀆅 checkmark
	static let checkmark = "checkmark"

	/// 􀐷 rectangle.compress.vertical
	static let collapse = "rectangle.compress.vertical"

	/// 􀉁 doc.on.doc
	static let copy = "doc.on.doc"

	/// 􀈄 square.and.arrow.down
	static let download = "square.and.arrow.down"

	/// 􀈊 pencil
	static let edit = "pencil"

	/// 􀋡 tag
	static let endpoint = "tag"

	/// 􀩳 list.bullet.rectangle
	static let environment = "list.bullet.rectangle"

	/// 􀇿 exclamationmark.triangle.fill
	static let error = "exclamationmark.triangle.fill"

	/// 􀐸 rectangle.expand.vertical
	static let expand = "rectangle.expand.vertical"

	/// 􀮵 arrow.up.forward.app
	static let external = "arrow.up.forward.app"

	/// 􀌈 line.3.horizontal.decrease.circle
	static let filter = "line.3.horizontal.decrease.circle"

	/// 􀌀 text.alignleft
	static let logs = "text.alignleft"

	/// 􀤆 network
	static let network = "network"

	/// 􀍠 ellipsis
	static let more = "ellipsis"

	/// 􀍡 ellipsis.circle
	static let moreCircle = "ellipsis.circle"

	static var _moreToolbar: String {
		if #available(iOS 26.0, macOS 26.0, *) {
			Self.more
		} else {
			Self.moreCircle
		}
	}

	/// 􀊅 pause
	static let pause = "pause"

	/// 􀆨 power
	static let power = "power"

	/// 􀅼 plus
	static let plus = "plus"

	/// 􀅍 questionmark
	static let questionMark = "questionmark"

	/// 􀅈 reload
	static let reload = "arrow.clockwise"

	/// 􀈑 trash
	static let remove = "trash"

	/// 􀊫 magnifyingglass
	static let search = "magnifyingglass"

	/// 􀍟 gear
	static let settings = "gear"

	/// 􀈂 square.and.arrow.up
	static let share = "square.and.arrow.up"

	/// 􀐞 square.stack.3d.up
	static let stack = "square.stack.3d.up"

	/// 􀊃 play
	static let start = "play"

	/// 􀛶 stop
	static let stop = "stop"

	/// 􀩼 terminal
	static let terminal = "terminal"

	/// 􀈂 square.and.arrow.up
	static let update = "square.and.arrow.up"

	/// 􀎬 safari
	static let web = "safari"

	/// 􀤂 externaldrive
	static let volume = "externaldrive"

	/// 􀆄 xmark
	static let xmark = "xmark"
}

// MARK: - SFSymbol+Custom

extension SFSymbol {
	enum Custom {
		/// custom.container
		static let container = "custom.container"
	}
}

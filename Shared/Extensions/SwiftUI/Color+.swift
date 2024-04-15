//
//  Color+.swift
//  Harbour
//
//  Created by royal on 22/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - Color+systemGray

extension Color {
	static var systemGray: Color {
		#if os(macOS)
		Color(nsColor: .systemGray)
		#else
		Color(uiColor: .systemGray5)
		#endif
	}
}

// MARK: - Color+lightGray

extension Color {
	static var lightGray: Color {
		#if os(macOS)
		Color(nsColor: .lightGray)
		#else
		Color(uiColor: .lightGray)
		#endif
	}
}

// MARK: - Color+darkGray

extension Color {
	static var darkGray: Color {
		#if os(macOS)
		Color(nsColor: .darkGray)
		#else
		Color(uiColor: .darkGray)
		#endif
	}
}

// MARK: - Color+secondaryBackground

extension Color {
	static var primaryBackground: Color {
		#if os(macOS)
		Color(nsColor: .controlBackgroundColor)
		#else
		Color(uiColor: .systemBackground)
		#endif
	}
}

// MARK: - Color+secondaryBackground

extension Color {
	static var secondaryBackground: Color {
		#if os(macOS)
		Color(nsColor: .controlBackgroundColor)
		#else
		Color(uiColor: .secondarySystemBackground)
		#endif
	}
}

// MARK: - Color+tertiaryBackground

extension Color {
	static var tertiaryBackground: Color {
		#if os(macOS)
		Color(nsColor: .controlBackgroundColor)
		#else
		Color(uiColor: .tertiarySystemBackground)
		#endif
	}
}

// MARK: - Color+groupedBackground

extension Color {
	static var groupedBackground: Color {
		#if os(macOS)
		Color(nsColor: .clear)
		#else
		Color(uiColor: .systemGroupedBackground)
		#endif
	}
}

// MARK: - Color+secondaryGroupedBackground

extension Color {
	static var secondaryGroupedBackground: Color {
		#if os(macOS)
		Color(nsColor: .controlBackgroundColor)
		#else
		Color(uiColor: .secondarySystemGroupedBackground)
		#endif
	}
}

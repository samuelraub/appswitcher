//
//  Constants.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 28.02.22.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let intelliJ = Self("intelliJ", default: .init(.j, modifiers: [.control]))
    static let chrome = Self("chrome", default: .init(.c, modifiers: [.control]))
}

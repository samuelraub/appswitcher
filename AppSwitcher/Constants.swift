//
//  Constants.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 28.02.22.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let app0 = Self("app0")
    static let app1 = Self("app1")
    static let app2 = Self("app2")
    static let app3 = Self("app3")
    static let app4 = Self("app4")
    static let app5 = Self("app5")
    static let app6 = Self("app6")
    static let app7 = Self("app7")
    static let app8 = Self("app8")
    static let app9 = Self("app9")
}
extension KeyboardShortcuts.Name: CaseIterable {
    public static let allCases: [Self] = [
        .app0,
        .app1,
        .app2,
        .app3,
        .app4,
        .app5,
        .app6,
        .app7,
        .app8,
        .app9,
    ]
}

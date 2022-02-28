//
//  AppSwitcherApp.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 28.02.22.
//

import SwiftUI
import KeyboardShortcuts

@main
struct AppSwitcherApp: App {
    @StateObject private var appState = AppState()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup("ContentView") {
            ContentView()
        }.handlesExternalEvents(matching: Set(arrayLiteral: "ContentView"))
    }
}

@MainActor
final class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyUp(for: .intelliJ) {
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.jetbrains.intellij") else { return }
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url,
                                               configuration: configuration,
                                               completionHandler: nil)
        }
        KeyboardShortcuts.onKeyUp(for: .chrome) {
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") else { return }
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url,
                                               configuration: configuration,
                                               completionHandler: nil)
        }
    }
}

class AppDelegate: NSObject,NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let MenuButton = statusItem?.button {
            MenuButton.image = NSImage(systemSymbolName: "squares.below.rectangle", accessibilityDescription: nil)
            MenuButton.action = #selector(MenuButtonToggle)
        }
    }
    
    @objc func MenuButtonToggle() {
        let window = NSApplication.shared.windows.filter { w in
            return w.title == "ContentView"
        }
        if window.isEmpty {
            OpenWindows.ContentView.open()
        }
    }
}

enum OpenWindows: String, CaseIterable {
    case ContentView = "ContentView"

    func open(){
        if let url = URL(string: "appswitcher://\(self.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}

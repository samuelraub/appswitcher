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
    @StateObject var appState = AppState()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup("Settings") {
            ContentView().environmentObject(appState)
        }.handlesExternalEvents(matching: Set(arrayLiteral: "Settings"))
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var apps: [String?] = (0...9).map {idx in
        return UserDefaults.standard.string(forKey: "app\(idx)")
    }
    
    @Published var jsonApps: StateApps = Helpers.getSettingsOrSetDefaults()!
}

class AppDelegate: NSObject,NSApplicationDelegate {
    var statusItem: NSStatusItem?
    @EnvironmentObject var appState: AppState
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let window = NSApplication.shared.windows.filter { w in
            return w.title == "Settings"
        }
        
        if !window.isEmpty {
            window[0].close()
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let MenuButton = statusItem?.button {
            MenuButton.image = NSImage(systemSymbolName: "squares.below.rectangle", accessibilityDescription: nil)
            MenuButton.action = #selector(MenuButtonToggle)
        }
    }
    
    @objc func MenuButtonToggle() {
        let window = NSApplication.shared.windows.filter { w in
            return w.title == "Settings"
        }
        if window.isEmpty {
            OpenWindows.Settings.open()
        } else {
            window[0].level = NSWindow.Level.floating
        }
    }
}

enum OpenWindows: String, CaseIterable {
    case Settings = "Settings"

    func open(){
        if let url = URL(string: "appswitcher://\(self.rawValue)") {
            NSWorkspace.shared.open(url)
        }
    }
}

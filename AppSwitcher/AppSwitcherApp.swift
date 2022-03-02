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
    
    @Published var jsonApps: StateApps = StorageBackend.getAll()
}

class AppDelegate: NSObject,NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let stateApps = StorageBackend.getAll()
        KeyboardShortcuts.removeAllHandlers()
        KeyboardShortcuts.reset(KeyboardShortcuts.Name.allCases)
        stateApps.apps.forEach {app in
            if app.shortcut != nil && app.value != nil {
                let sc = KeyboardShortcuts.Shortcut.init(carbonKeyCode: app.shortcut!.carbonKeyCode, carbonModifiers: app.shortcut!.carbonModifiers)
                if let name = KeyboardShortcuts.Name.allCases.first(where: {$0.rawValue == app.key}) {
                    KeyboardShortcuts.setShortcut(sc, for: name)
                    KeyboardShortcuts.onKeyUp(for: name) {
                        guard let url = NSWorkspace.shared.urlForApplication(toOpen: Helpers.stringToUrl(str: app.value!)!) else {
                            return
                        }
                        let configuration = NSWorkspace.OpenConfiguration()
                        NSWorkspace.shared.openApplication(at: url,
                                                           configuration: configuration,
                                                           completionHandler: nil)
                    }
                }
            }
        }
        
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

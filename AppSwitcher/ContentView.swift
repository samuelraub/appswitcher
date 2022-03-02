//
//  ContentView.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 28.02.22.
//

import SwiftUI
import KeyboardShortcuts
import FilePicker

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Form {
            VStack(alignment: .trailing) {
                ForEach(0..<appState.apps.count) { idx in
                    HStack {
                        let app = appState.jsonApps.apps[idx]
                        if app.value != nil {
                            Text(URL(string: app.value!)?.lastPathComponent ?? "None")
                            Button("Clear", action: {
                                if let newStateApps = try? StorageBackend.storeApp(
                                    app: StateApp(key: app.key, value: nil, shortcut: nil),
                                    state: appState.jsonApps) {
                                    appState.jsonApps = newStateApps
                                }
                            })
                        } else {
                            FilePicker(types: [.applicationBundle], allowMultiple: false, title: "Pick an Application") { urls in
                                if !urls.isEmpty {
                                    let url = urls[0]
                                    let scName = KeyboardShortcuts.Name.allCases[idx]
                                    KeyboardShortcuts.onKeyUp(for: scName) {
                                        guard let url = NSWorkspace.shared.urlForApplication(toOpen: url) else { return }
                                        let configuration = NSWorkspace.OpenConfiguration()
                                        NSWorkspace.shared.openApplication(at: url,
                                                                           configuration: configuration,
                                                                           completionHandler: nil)
                                    }
                                    if let sc = KeyboardShortcuts.getShortcut(for: scName) {
                                        if let newStateApps = try? StorageBackend.storeApp(app: StateApp(
                                            key: app.key, value: Helpers.urlToString(url: url), shortcut: StateAppShortcurt(
                                                carbonModifiers: sc.carbonModifiers, carbonKeyCode: sc.carbonKeyCode)
                                            ), state: appState.jsonApps) {
                                            appState.jsonApps = newStateApps
                                        }
                                    } else {
                                        if let newStateApps = try? StorageBackend.storeApp(app: StateApp(
                                                key: app.key, value: Helpers.urlToString(url: url), shortcut: nil
                                            ), state: appState.jsonApps) {
                                            appState.jsonApps = newStateApps
                                        }
                                    }
                                }
                            }
                        }
                        KeyboardShortcuts.Recorder(for: KeyboardShortcuts.Name.allCases[idx])
                    }
                }
            }
        }.frame(minWidth: 640, idealWidth: 640, minHeight: 480, idealHeight: 480)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

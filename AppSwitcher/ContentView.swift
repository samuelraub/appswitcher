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
    @State var saved: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text("AppSwitcher").font(.title).padding()
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
            }.padding()
            VStack {
                Button("Save", action: {
                    let stateApps = StorageBackend.getAll()
                    let newStateApps: [StateApp] = stateApps.apps.map {app in
                        let name = KeyboardShortcuts.Name.allCases.first(where: {$0.rawValue == app.key})!
                        let sc = KeyboardShortcuts.getShortcut(for: name)
                        return StateApp(key: app.key, value: app.value, shortcut: sc == nil ? nil : StateAppShortcurt(
                            carbonModifiers: sc!.carbonModifiers, carbonKeyCode: sc!.carbonKeyCode
                        ))
                    }
                    do {
                        try StorageBackend.storeAll(state: StateApps(apps: newStateApps))
                        saved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            saved = false
                        }
                    } catch {
                        saved = false
                    }
                }).keyboardShortcut(.defaultAction)
                if saved {
                    Text("Settings saved!")
                }
                Spacer()
                Text("Settings: \(Helpers.getDocumentsDirectory().appendingPathComponent("settings.json").relativePath)")
                    .font(.system(size: 12.0))
                    .textSelection(.enabled)
                Button("Reveal in Finder", action: {
                        let files = [URL(fileURLWithPath: Helpers.getDocumentsDirectory().appendingPathComponent("settings.json").relativePath)];
                        NSWorkspace.shared.activateFileViewerSelecting(files);
                    }
                )
            }.padding()
        }.frame(minWidth: 800, idealWidth: 800, minHeight: 600, idealHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

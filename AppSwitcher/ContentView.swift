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
                                appState.apps[idx] = nil
                            })
                        } else {
                            FilePicker(types: [.applicationBundle], allowMultiple: false, title: "Pick an Application") { urls in
                                if !urls.isEmpty {
                                    appState.apps[idx] = urls[0].absoluteString
                                    let stateApps = Helpers.registerShortcut(key: "app\(idx)", value: urls[0], state: appState.jsonApps)
                                    if stateApps != nil {
                                        appState.jsonApps = stateApps!
                                    }
                                }
                            }
                        }
                        KeyboardShortcuts.Recorder(for: KeyboardShortcuts.Name.allCases[idx])
                    }
                }
                Button("Reveal settings in Finder", action: {
                    let url = Bundle.main.url(forResource: "settings", withExtension: "json")?.deletingLastPathComponent()
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url!.relativePath)
                })
            }
        }.frame(minWidth: 640, idealWidth: 640, minHeight: 480, idealHeight: 480)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

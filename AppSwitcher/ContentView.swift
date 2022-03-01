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
                        let app = appState.apps[idx]
                        if app != nil {
                            Text(URL(string: app!)?.lastPathComponent ?? "None")
                            Button("Clear", action: {
                                appState.apps[idx] = nil
                                print(appState.jsonApps)
                                UserDefaults.standard.set(nil, forKey: "app\(idx)")
                            })
                        } else {
                            FilePicker(types: [.applicationBundle], allowMultiple: false, title: "Pick an Application") { urls in
                                if !urls.isEmpty {
                                    appState.apps[idx] = urls[0].absoluteString
                                    Helpers.registerShortcut(key: "app\(idx)", value: urls[0])
                                } else {
                                    appState.apps[0] = nil
                                    UserDefaults.standard.set(nil, forKey: "app\(idx)")
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

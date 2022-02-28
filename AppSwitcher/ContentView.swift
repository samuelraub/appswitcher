//
//  ContentView.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 28.02.22.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
    var body: some View {
        Form {
            VStack(alignment: .trailing) {
                HStack(alignment: .center) {
                    Text("Switch to IntelliJ:")
                    KeyboardShortcuts.Recorder(for: .intelliJ)
                }
                HStack(alignment: .center) {
                    Text("Switch to Chrome:")
                    KeyboardShortcuts.Recorder(for: .chrome)
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

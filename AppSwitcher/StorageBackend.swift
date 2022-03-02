//
//  StorageBackend.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 02.03.22.
//

import Foundation

struct StateAppShortcurt: Codable {
    let carbonModifiers: Int
    let carbonKeyCode: Int
}

struct StateApp: Codable {
    let key: String
    let value: String?
    let shortcut: StateAppShortcurt?
}

struct StateApps: Codable {
    let apps: [StateApp]
}

class StorageBackend {
    static func storeAll(state: StateApps) throws {
        let enc = JSONEncoder()
        enc.outputFormatting = .prettyPrinted
        let json = try enc.encode(state)
        let url = Helpers.getDocumentsDirectory().appendingPathComponent("settings.json")
        let str = String(data: json, encoding: .utf8)!
        try str.write(to: url, atomically: true, encoding: .utf8)
    }
    
    static func getAll() -> StateApps {
        do {
            let path = Helpers.getDocumentsDirectory().appendingPathComponent("settings.json").relativePath
            let data = try String(contentsOfFile: path).data(using: .utf8)
            let dec = JSONDecoder()
            let apps = try dec.decode(StateApps.self, from: data!)
            return apps
        } catch {
            let apps = setDefaults()
            return apps
        }
    }
    
    static func setDefaults() -> StateApps {
        let fm = FileManager.default
        let resUrl = Bundle.main.url(forResource: "settings", withExtension: "json")
        try? fm.copyItem(at: resUrl!, to: Helpers.getDocumentsDirectory().appendingPathComponent("settings.json"))
        return getAll()
    }
    
    static func storeApp(app: StateApp, state: StateApps) throws -> StateApps {
        let newStateApps: [StateApp] = state.apps.map {stateApp in
            if app.key == stateApp.key {
                return app
            }
            return stateApp
        }
        try storeAll(state: StateApps(apps: newStateApps))
        return StateApps(apps: newStateApps)
    }
    
    static func getApp(key: String, state: StateApps) -> StateApp? {
        return state.apps.first(where: { $0.key == key })
    }
}

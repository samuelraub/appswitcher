//
//  Helpers.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 01.03.22.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

struct StateApp: Codable {
    let key: String
    let value: String?
}

struct StateApps: Codable {
    let apps: [StateApp]
}

class Helpers {
    static func urlToString(url: URL) -> String {
        return url.absoluteString
    }
    
    static func stringToUrl(str: String) -> URL? {
        return URL(string: str)
    }
    
    static func registerShortcut(key: String, value: URL) {
        let kkey = KeyboardShortcuts.Name.allCases.first(where: {$0.rawValue == key})?.rawValue as String?
        let idx = KeyboardShortcuts.Name.allCases.firstIndex(where: {$0.rawValue == key})
        if kkey == nil || idx == nil{
            return
        }
        UserDefaults.standard.set(urlToString(url: value), forKey: kkey!)
        KeyboardShortcuts.onKeyUp(for: KeyboardShortcuts.Name.allCases[idx!]) {
            guard let url = NSWorkspace.shared.urlForApplication(toOpen: value) else { return }
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url,
                                               configuration: configuration,
                                               completionHandler: nil)
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func toJson(data: StateApps) -> Bool? {
        do {
            let enc = JSONEncoder()
            enc.outputFormatting = .prettyPrinted
            let json = try enc.encode(data)
            let url = getDocumentsDirectory().appendingPathComponent("settings.json")
            print(url.absoluteString)
            let str = String(data: json, encoding: .utf8)!
            try str.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            print(error)
            return nil
        }
    }
    
    static func fromJson() -> StateApps? {
        do {
            let path = getDocumentsDirectory().appendingPathComponent("settings.json").relativePath
            let data = try String(contentsOfFile: path).data(using: .utf8)
            if data == nil {
                return nil
            }
            let dec = JSONDecoder()
            let apps = try dec.decode(StateApps.self, from: data!)
            return apps
        } catch {
            print(error)
            return nil
        }
    }
}

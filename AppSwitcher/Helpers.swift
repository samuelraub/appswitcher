//
//  Helpers.swift
//  AppSwitcher
//
//  Created by Samuel Raub on 01.03.22.
//

import Foundation

class Helpers {
    static func test() {
        print(getDocumentsDirectory().appendingPathComponent("settings.json"))
    }
    
    static func urlToString(url: URL) -> String {
        return url.absoluteString
    }
    
    static func stringToUrl(str: String) -> URL? {
        return URL(string: str)
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

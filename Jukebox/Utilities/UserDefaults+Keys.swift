//
//  UserDefaults+Keys.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 19/1/2022.
//

import Foundation

extension UserDefaults {
    @objc dynamic var connectedApp: String {
        return string(forKey: "connectedApp")!
    }
    
    @objc dynamic var statusTextStyle: String {
        return string(forKey: "statusTextStyle")!
    }
    
    @objc dynamic var statusBarWidthLimit: String {
        return string(forKey: "statusBarWidthLimit")!
    }
    
    @objc dynamic var showAnimation: String {
        return string(forKey: "showAnimation")!
    }
    
    @objc dynamic var statusBarTextSpeed: String {
        return string(forKey: "statusBarTextSpeed")!
    }
}

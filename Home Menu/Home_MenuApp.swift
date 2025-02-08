//
//  Home_MenuApp.swift
//  Home Menu
//
//  Created by mac on 2025/2/6.
//

import SwiftUI
import FirebaseCore

@main
struct Home_MenuApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

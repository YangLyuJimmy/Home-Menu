//
//  ContentView.swift
//  Home Menu
//
//  Created by mac on 2025/2/6.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var menuManager = MenuManager()
    @StateObject private var authService = AuthenticationService()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                // Main app content
                TabView(selection: $selectedTab) {
                    MyMenuView()
                        .tabItem {
                            Label("My Menu", systemImage: "list.bullet")
                        }
                        .tag(0)
                    
                    SharedMenusView()
                        .tabItem {
                            Label("Shared Menu", systemImage: "square.and.arrow.up")
                        }
                        .tag(1)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                        .tag(2)
                }
                .environmentObject(menuManager)
            } else {
                LoginView()
            }
        }
        .environmentObject(authService)
    }
}

#Preview {
    ContentView()
}

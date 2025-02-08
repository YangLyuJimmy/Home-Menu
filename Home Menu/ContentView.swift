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

struct MyMenuView: View {
    @EnvironmentObject var menuManager: MenuManager
    @State private var showingAddItem = false
    @State private var itemToEdit: MenuItem?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(menuManager.myMenu.items) { item in
                    MenuItemRow(item: item)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                menuManager.deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                itemToEdit = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .navigationTitle("My Menu")
            .toolbar {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                MenuItemFormView(menuManager: menuManager)
            }
            .sheet(item: $itemToEdit) { item in
                MenuItemFormView(menuManager: menuManager, editingItem: item)
            }
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                if !item.isAvailable {
                    Text("Unavailable")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Label(item.category.rawValue, systemImage: item.category.icon)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}

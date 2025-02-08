import SwiftUI

struct SharedMenusView: View {
    @EnvironmentObject var menuManager: MenuManager
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section("My Menu") {
                    MenuRow(menu: menuManager.myMenu)
                }
                
                Section("Shared With Me") {
                    if menuManager.sharedMenus.isEmpty {
                        Text("No menus shared with you yet")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(menuManager.sharedMenus) { menu in
                            MenuRow(menu: menu)
                        }
                    }
                }
            }
            .navigationTitle("Shared Menu")
            .toolbar {
                Button {
                    showingShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareMenuSheet()
            }
        }
    }
}

struct MenuRow: View {
    let menu: Menu
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(menu.title)
                .font(.headline)
            Text("By \(menu.ownerName)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
} 

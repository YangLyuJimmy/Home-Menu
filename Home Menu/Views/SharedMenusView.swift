import SwiftUI

struct SharedMenusView: View {
    @EnvironmentObject var menuManager: MenuManager
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingShareSheet = false
    @State private var showingJoinSheet = false
    @State private var roomNumberToJoin = ""
    @State private var selectedItems = Set<UUID>()
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var sharingDuration = 1 // Default 1 day
    
    var body: some View {
        NavigationView {
            List {
                // My Shared Menu Section
                Section(header: Text("My Shared Menu")) {
                    if let roomNumber = menuManager.myMenu.roomNumber {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Active Room: ")
                                    .font(.headline)
                                Text(roomNumber)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    UIPasteboard.general.string = roomNumber
                                }) {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            
                            Button("Share Room Code") {
                                showingShareSheet = true
                            }
                            .padding(.vertical, 8)
                        }
                    } else {
                        Text("No active sharing room")
                            .foregroundColor(.gray)
                        
                        Picker("Share for:", selection: $sharingDuration) {
                            Text("1 day").tag(1)
                            Text("3 days").tag(3)
                            Text("7 days").tag(7)
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 8)
                        
                        Button("Create Sharing Room") {
                            if let userId = authService.currentUser?.id {
                                menuManager.generateRoomNumber(userId: userId, durationInDays: sharingDuration)
                            } else {
                                errorMessage = "You must be logged in to share"
                                showError = true
                            }
                        }
                        .disabled(menuManager.myMenu.items.isEmpty)
                    }
                }
                
                // Select Items to Share
                Section(header: Text("Select Items to Share")) {
                    if menuManager.myMenu.items.isEmpty {
                        Text("Your menu is empty")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(menuManager.myMenu.items) { item in
                            Button(action: {
                                if selectedItems.contains(item.id) {
                                    selectedItems.remove(item.id)
                                } else {
                                    selectedItems.insert(item.id)
                                }
                            }) {
                                HStack {
                                    MenuItemRow(item: item)
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedItems.contains(item.id) ? .blue : .gray)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Button("Share Selected Items") {
                            shareSelectedItems()
                        }
                        .disabled(selectedItems.isEmpty)
                        .padding(.vertical, 8)
                    }
                }
                
                // Join Room
                Section(header: Text("Join Room")) {
                    HStack {
                        TextField("Enter room number", text: $roomNumberToJoin)
                            .keyboardType(.numberPad)
                        
                        Button("Join") {
                            if !roomNumberToJoin.isEmpty {
                                menuManager.joinRoom(number: roomNumberToJoin)
                                roomNumberToJoin = ""
                            }
                        }
                        .disabled(roomNumberToJoin.isEmpty)
                    }
                }
                
                // Shared Menus
                if !menuManager.sharedMenus.isEmpty {
                    Section(header: Text("Shared Menus")) {
                        ForEach(menuManager.sharedMenus) { menu in
                            NavigationLink(destination: SharedMenuDetailView(menu: menu)) {
                                VStack(alignment: .leading) {
                                    Text(menu.title)
                                        .font(.headline)
                                    Text("By: \(menu.ownerName)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Items: \(menu.items.count)")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Share Menu")
            .sheet(isPresented: $showingShareSheet) {
                if let roomNumber = menuManager.myMenu.roomNumber {
                    ShareSheet(activityItems: ["Join my Home Menu with code: \(roomNumber)"])
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func shareSelectedItems() {
        // Create text to share
        var shareText = "Check out these items from my menu:\n\n"
        
        let items = menuManager.myMenu.items.filter { selectedItems.contains($0.id) }
        for item in items {
            shareText += "• \(item.name): \(item.description)\n"
        }
        
        if let roomNumber = menuManager.myMenu.roomNumber {
            shareText += "\nJoin my complete menu with code: \(roomNumber)"
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Present the activity view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// Helper view for shared menu details
struct SharedMenuDetailView: View {
    let menu: Menu
    
    var body: some View {
        List {
            Section(header: Text("Menu Information")) {
                HStack {
                    Text("Owner:")
                    Spacer()
                    Text(menu.ownerName)
                }
                
                HStack {
                    Text("Last Updated:")
                    Spacer()
                    Text(menu.lastUpdated.formatted())
                        .font(.caption)
                }
            }
            
            Section(header: Text("Items")) {
                if menu.items.isEmpty {
                    Text("No items in this menu")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(menu.items) { item in
                        MenuItemRow(item: item)
                    }
                }
            }
        }
        .navigationTitle(menu.title)
    }
}

// Helper structure to handle system share sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SharedMenusView()
        .environmentObject(MenuManager())
        .environmentObject(AuthenticationService())
}


import Foundation

class MenuManager: ObservableObject {
    @Published var myMenu: Menu
    @Published var sharedMenus: [Menu] = []
    private let firebaseService = FirebaseService()
    
    init() {
        self.myMenu = Menu(
            ownerName: "Me",
            title: "My Menu",
            items: []
        )
    }
    
    func addItem(_ item: MenuItem) {
        myMenu.items.append(item)
    }
    
    func updateItem(_ item: MenuItem) {
        if let index = myMenu.items.firstIndex(where: { $0.id == item.id }) {
            myMenu.items[index] = item
        }
    }
    
    func deleteItem(_ item: MenuItem) {
        myMenu.items.removeAll { $0.id == item.id }
    }
    
    @MainActor
    func generateRoomNumber(userId: String, durationInDays: Int = 1) {
        Task {
            do {
                let room = try await firebaseService.createRoom(
                    menu: myMenu,
                    userId: userId,  // Use actual user ID
                    durationInDays: durationInDays
                )
                myMenu.roomNumber = room.roomNumber
            } catch {
                print("Error creating room: \(error)")
            }
        }
    }
    
    @MainActor
    func joinRoom(number: String) {
        Task {
            do {
                guard let room = try await firebaseService.getRoom(number: number) else {
                    print("Room not found or expired")
                    return
                }
                
                if let sharedMenu = try await firebaseService.getMenu(id: room.menuId) {
                    if !sharedMenus.contains(where: { $0.id == sharedMenu.id }) {
                        sharedMenus.append(sharedMenu)
                    }
                }
            } catch {
                print("Error joining room: \(error)")
            }
        }
    }
} 

import Foundation
import FirebaseFirestore

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    
    func createRoom(menu: Menu, userId: String, durationInDays: Int = 1) async throws -> Room {
        let roomNumber = String(format: "%06d", Int.random(in: 100000...999999))
        let room = Room.create(
            roomNumber: roomNumber,
            userId: userId,
            menuId: menu.id.uuidString,
            durationInDays: durationInDays
        )
        
        let roomData: [String: Any] = [
            "roomNumber": room.roomNumber,
            "userId": room.userId,
            "menuId": room.menuId,
            "creationDate": room.creationDate,
            "expirationDate": room.expirationDate
        ]
        
        try await db.collection("rooms").document(roomNumber).setData(roomData)
        
        // Store menu data
        let menuData: [String: Any] = [
            "id": menu.id.uuidString,
            "ownerName": menu.ownerName,
            "title": menu.title,
            "items": try JSONEncoder().encode(menu.items).base64EncodedString(),
            "lastUpdated": menu.lastUpdated
        ]
        
        try await db.collection("menus").document(menu.id.uuidString).setData(menuData)
        
        return room
    }
    
    func getRoom(number: String) async throws -> Room? {
        let doc = try await db.collection("rooms").document(number).getDocument()
        guard let data = doc.data() else { return nil }
        
        let room = Room(
            roomNumber: data["roomNumber"] as? String ?? "",
            userId: data["userId"] as? String ?? "",
            menuId: data["menuId"] as? String ?? "",
            creationDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
            expirationDate: (data["expirationDate"] as? Timestamp)?.dateValue() ?? Date()
        )
        
        // Check if room is expired
        guard !room.isExpired else {
            // Delete expired room
            try await db.collection("rooms").document(number).delete()
            return nil
        }
        
        return room
    }
    
    func getMenu(id: String) async throws -> Menu? {
        let doc = try await db.collection("menus").document(id).getDocument()
        guard let data = doc.data() else { return nil }
        
        guard let itemsString = data["items"] as? String,
              let itemsData = Data(base64Encoded: itemsString),
              let items = try? JSONDecoder().decode([MenuItem].self, from: itemsData) else {
            return nil
        }
        
        return Menu(
            id: UUID(uuidString: data["id"] as? String ?? "") ?? UUID(),
            ownerName: data["ownerName"] as? String ?? "",
            title: data["title"] as? String ?? "",
            items: items,
            lastUpdated: (data["lastUpdated"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
} 
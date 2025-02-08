import Foundation
import FirebaseFirestore

struct Room: Codable {
    let roomNumber: String
    let userId: String
    let menuId: String
    let creationDate: Date
    let expirationDate: Date
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
}

extension Room {
    static func create(roomNumber: String, userId: String, menuId: String, durationInDays: Int = 1) -> Room {
        let creation = Date()
        // Ensure duration is between 1 and 7 days
        let days = min(max(durationInDays, 1), 7)
        let expiration = Calendar.current.date(byAdding: .day, value: days, to: creation) ?? creation.addingTimeInterval(86400)
        
        return Room(
            roomNumber: roomNumber,
            userId: userId,
            menuId: menuId,
            creationDate: creation,
            expirationDate: expiration
        )
    }
} 
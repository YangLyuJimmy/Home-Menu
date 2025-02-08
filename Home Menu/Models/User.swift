import Foundation

struct User: Codable, Identifiable {
    let id: String  // Firebase user ID
    var username: String
    var email: String
    var createdAt: Date
    
    init(id: String, username: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = createdAt
    }
} 
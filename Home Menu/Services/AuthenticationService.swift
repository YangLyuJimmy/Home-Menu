import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor  // This ensures all UI updates happen on main thread
class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    private let db = Firestore.firestore()
    
    init() {
        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in  // Ensure UI updates on main thread
                if let firebaseUser = firebaseUser {
                    do {
                        try await self?.fetchUser(userId: firebaseUser.uid)
                    } catch {
                        print("Error fetching user: \(error)")
                        self?.currentUser = nil
                    }
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        try await fetchUser(userId: result.user.uid)
    }
    
    func signUp(username: String, email: String, password: String) async throws {
        // First create the auth user
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Then create our app user
        let newUser = User(
            id: result.user.uid,
            username: username,
            email: email
        )
        
        // Store user data in Firestore
        try await storeUserData(newUser)
        
        // Update the current user
        self.currentUser = newUser
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.currentUser = nil
    }
    
    private func fetchUser(userId: String) async throws {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let data = document.data() else { throw AuthError.userNotFound }
        
        self.currentUser = User(
            id: userId,
            username: data["username"] as? String ?? "",
            email: data["email"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    private func storeUserData(_ user: User) async throws {
        try await db.collection("users").document(user.id).setData([
            "username": user.username,
            "email": user.email,
            "createdAt": Timestamp(date: user.createdAt)
        ])
    }
}

enum AuthError: LocalizedError {
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        }
    }
} 
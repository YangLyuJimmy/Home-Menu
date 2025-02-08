import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        NavigationView {
            Form {
                if let user = authService.currentUser {
                    Section("User Information") {
                        HStack {
                            Text("Username:")
                            Spacer()
                            Text(user.username)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Email:")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Member Since:")
                            Spacer()
                            Text(user.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        do {
                            try authService.signOut()
                        } catch {
                            print("Error signing out: \(error)")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
} 
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isRegistering = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
            VStack(spacing: 20) {
                Text(isRegistering ? "Create Account" : "Welcome!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                if isRegistering {
                    HStack {
                        Image(systemName: "person.fill.viewfinder")
                            .padding(.horizontal, 1)
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal)
                }
                    
                HStack {
                    Image(systemName: "envelope")
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "key.horizontal")
                    SecureFieldView(text: $password)
                }
                .padding(.horizontal)
                
                
                Button(action: submit) {
                    Text(isRegistering ? "Register" : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isValid)
                .padding(.horizontal)
                
                Button {
                    withAnimation {
                        isRegistering.toggle()
                        username = ""
                        email = ""
                        password = ""
                    }
                } label: {
                    Text(isRegistering ? "Already have an account? Login" : "New user? Register")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    
        private var isValid: Bool {
            if isRegistering {
                return !username.isEmpty && isValidEmail && password.count >= 6
            } else {
                return isValidEmail && !password.isEmpty
            }
        }
        
        private var isValidEmail: Bool {
            let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            return email.range(of: emailRegex, options: .regularExpression) != nil
        }
        
        @MainActor
        private func submit() {
            Task {
                do {
                    if isRegistering {
                        print("Starting registration process...")
                        try await authService.signUp(
                            username: username,
                            email: email,
                            password: password
                        )
                        print("Registration completed successfully")
                    } else {
                        print("Starting sign in process...")
                        try await authService.signIn(
                            email: email,
                            password: password
                        )
                        print("Sign in completed successfully")
                    }
                } catch let error as AuthError {
                    errorMessage = error.errorDescription ?? "An unknown error occurred"
                    showError = true
                    print("Auth error: \(errorMessage)")
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                    print("General error: \(error)")
                }
            }
        }
    }



#Preview {
    LoginView()
        .environmentObject(AuthenticationService())
} 

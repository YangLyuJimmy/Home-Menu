import SwiftUI

struct ShareMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var menuManager: MenuManager
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var roomNumber = ""
    @State private var selectedDuration = 1
    
    let durations = [1, 2, 3, 4, 5, 6, 7]
    
    var body: some View {
        NavigationView {
            Form {
                existingRoomSection
                generateRoomSection
                joinRoomSection
            }
            .navigationTitle("Share Menu")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var existingRoomSection: some View {
        Group {
            if let existingRoom = menuManager.myMenu.roomNumber {
                Section("Your Room Number") {
                    Text(existingRoom)
                        .font(.title2)
                        .monospaced()
                    
                    Text("Share this number with others to let them join your menu")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var generateRoomSection: some View {
        Group {
            if menuManager.myMenu.roomNumber == nil {
                VStack {
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(durations, id: \.self) { days in
                            Text("\(days) \(days == 1 ? "day" : "days")")
                                .tag(days)
                        }
                    }
                    
                    Button("Generate Room Number") {
                        if let userId = authService.currentUser?.id {
                            menuManager.generateRoomNumber(userId: userId, durationInDays: selectedDuration)
                        }
                    }
                }
            }
        }
    }
    
    private var joinRoomSection: some View {
        Section("Join a Room") {
            TextField("Enter room number", text: $roomNumber)
                .keyboardType(.numberPad)
            
            Button("Join") {
                menuManager.joinRoom(number: roomNumber)
                dismiss()
            }
            .disabled(roomNumber.count != 6)
        }
    }
} 

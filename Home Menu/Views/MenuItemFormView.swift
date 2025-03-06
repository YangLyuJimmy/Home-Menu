import SwiftUI

struct MenuItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var menuManager: MenuManager
    
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var selectedCategory: FoodCategory = .mixed
    @State private var isAvailable = true
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case name
        case description
    }
    
    var editingItem: MenuItem? = nil
    
    init(menuManager: MenuManager, editingItem: MenuItem? = nil) {
        self.menuManager = menuManager
        self.editingItem = editingItem
        
        if let item = editingItem {
            _itemName = State(initialValue: item.name)
            _itemDescription = State(initialValue: item.description)
            _selectedCategory = State(initialValue: item.category)
            _isAvailable = State(initialValue: item.isAvailable)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Food Name:")
                            .foregroundColor(.black)
                        TextField("Enter food name", text: $itemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .name)
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedField == .name ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description:")
                            .foregroundColor(.black)
                        TextField("Enter description", text: $itemDescription, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($focusedField, equals: .description)
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedField == .description ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .animation(.easeInOut(duration: 0.2), value: focusedField)
                            .lineLimit(3...6)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category:")
                            .foregroundColor(.black)
                        Picker("", selection: $selectedCategory) {
                            ForEach(FoodCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Toggle("Available", isOn: $isAvailable)
                }
            }
            .navigationTitle(editingItem == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        let newItem = MenuItem(
            id: editingItem?.id ?? UUID(),
            name: itemName,
            description: itemDescription,
            category: selectedCategory,
            isAvailable: isAvailable
        )
        
        if editingItem != nil {
            menuManager.updateItem(newItem)
        } else {
            menuManager.addItem(newItem)
        }
    }
}

#Preview {
    MenuItemFormView(menuManager: MenuManager())
} 

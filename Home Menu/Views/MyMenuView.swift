import SwiftUI

struct MyMenuView: View {
    @EnvironmentObject var menuManager: MenuManager
    @State private var showingAddItem = false
    @State private var itemToEdit: MenuItem?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(menuManager.myMenu.items) { item in
                    MenuItemRow(item: item)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                menuManager.deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                itemToEdit = item
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .navigationTitle("My Menu")
            .toolbar {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddItem) {
                MenuItemFormView(menuManager: menuManager)
            }
            .sheet(item: $itemToEdit) { item in
                MenuItemFormView(menuManager: menuManager, editingItem: item)
            }
        }
    }
}

#Preview {
    MyMenuView()
        .environmentObject(MenuManager())
} 

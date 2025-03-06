import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.name)
                    .font(.headline)
                Spacer()
                if !item.isAvailable {
                    Text("Unavailable")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            Label(item.category.rawValue, systemImage: item.category.icon)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MenuItemRow(item: MenuItem(
        name: "Sample Item",
        description: "This is a sample menu item description",
        category: .mixed,
        isAvailable: true
    ))
    .previewLayout(.sizeThatFits)
    .padding()
} 
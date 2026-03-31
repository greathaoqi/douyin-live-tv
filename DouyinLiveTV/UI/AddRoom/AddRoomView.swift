import SwiftUI

struct AddRoomView: View {
    @State private var roomInput: String = ""

    var body: some View {
        VStack(spacing: 32) {
            Text("Add Room")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.primary)

            TextField("Enter room ID or URL", text: $roomInput)
                .frame(minHeight: 88)
                .focusable()
                .focusEffect()
                .background(.systemBackground)
                .cornerRadius(8)
        }
        .safeAreaPadding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.systemBackground)
    }
}

#Preview(traits: .defaultLayout) {
    AddRoomView()
}

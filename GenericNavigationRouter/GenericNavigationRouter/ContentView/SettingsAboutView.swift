import SwiftUI

struct SettingsAboutView: View {
    @ObservedObject var router: NavigationRouter<SettingsRoute, AppSheet>

    var body: some View {
        VStack(spacing: 16) {
            Text("About")
                .font(.title2)

            Button("Pop") {
                router.pop()
            }
        }
        .padding()
        .navigationTitle("About")
    }
}

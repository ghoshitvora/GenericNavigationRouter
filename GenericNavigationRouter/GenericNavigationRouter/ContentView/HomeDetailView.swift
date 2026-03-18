import SwiftUI

struct HomeDetailView: View {
    let id: Int
    @ObservedObject var router: NavigationRouter<HomeRoute, AppSheet>

    var body: some View {
        VStack(spacing: 16) {
            Text("Detail ID: \(id)")
                .font(.title2)

            Button("Pop") {
                router.pop()
            }

            Button("Pop To Root") {
                router.popToRoot()
            }
        }
        .padding()
        .navigationTitle("Detail")
    }
}

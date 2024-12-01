import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        VStack {
            Text("Welcome, \(userSession.username ?? "Guest")!")
                .font(.title)
                .padding()

            Button(action: {
                userSession.logout() // Logout the user
            }) {
                Text("Logout")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}


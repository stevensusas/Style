import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var discounts: [String] = []
    @State private var totalDiscounts: Int = 0
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(userSession.username ?? "Guest")!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 20)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Discounts")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if discounts.isEmpty {
                    Text("You have no discounts yet.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(discounts, id: \.self) { discount in
                                HStack {
                                    Text("• \(discount)")
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                DiscountStatWidget(title: "Total Discounts", value: "\(totalDiscounts)")
                DiscountStatWidget(title: "Active Discounts", value: "\(discounts.count)")
                DiscountStatWidget(title: "Expired Discounts", value: "\(totalDiscounts - discounts.count)")
            }
            .padding(.bottom, 20)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            loadUserData()
        }
    }

    // Fetch user discounts and stats from backend
    private func loadUserData() {
        guard let username = userSession.username else {
            errorMessage = "Username not found."
            return
        }

        // Fetch discounts and total discounts in parallel
        APIService.shared.fetchUserDiscounts(username: username) { result in
            switch result {
            case .success(let userDiscounts):
                DispatchQueue.main.async {
                    discounts = userDiscounts
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
        }

        APIService.shared.fetchTotalDiscounts(username: username) { result in
            switch result {
            case .success(let total):
                DispatchQueue.main.async {
                    totalDiscounts = total
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Widget for displaying discount stats
struct DiscountStatWidget: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 10) {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(width: 100, height: 100)
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.pink, Color.orange]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// Tab Bar with 4 items
struct TabBar: View {
    @State private var selectedTab: Tab

    enum Tab {
        case friends, feed, trade, profile
    }

    init(selectedTab: Tab) {
        self._selectedTab = State(initialValue: selectedTab)
    }

    var body: some View {
        HStack {
            // Friends Tab
            Button(action: { selectedTab = .friends }) {
                VStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(selectedTab == .friends ? .blue : .gray)
                    Text("Friends")
                        .font(.caption)
                        .foregroundColor(selectedTab == .friends ? .blue : .gray)
                }
            }
            Spacer()

            // Feed Tab
            Button(action: { selectedTab = .feed }) {
                VStack {
                    Image(systemName: "house.fill")
                        .foregroundColor(selectedTab == .feed ? .blue : .gray)
                    Text("Feed")
                        .font(.caption)
                        .foregroundColor(selectedTab == .feed ? .blue : .gray)
                }
            }
            Spacer()

            // Trade Tab
            Button(action: {
                selectedTab = .trade
            }) {
                VStack {
                    Image(systemName: "cart.fill")
                        .foregroundColor(selectedTab == .trade ? .blue : .gray)
                    Text("Trade")
                        .font(.caption)
                        .foregroundColor(selectedTab == .trade ? .blue : .gray)
                }
            }
            Spacer()

            // Profile Tab
            Button(action: { selectedTab = .profile }) {
                VStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(selectedTab == .profile ? .blue : .gray)
                    Text("Profile")
                        .font(.caption)
                        .foregroundColor(selectedTab == .profile ? .blue : .gray)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserSession())
    }
}

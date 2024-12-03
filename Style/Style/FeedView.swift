import SwiftUI
import Foundation

struct FeedView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var currentDeal: Deal?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var timeUntilNextDeal: String = ""
    @State private var isDealSaved: Bool = false
    
    // Keys for UserDefaults
    private let lastUpdateKey = "lastDealUpdateTime"
    private let currentDealKey = "currentDealData"
    private let dealSavedKey = "dealSavedToday"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                        Spacer()
                    } else if let error = errorMessage {
                        ErrorView(message: error)
                    } else if isDealSaved {
                        DealSavedView(timeUntilNextDeal: timeUntilNextDeal)
                    } else if let deal = currentDeal {
                        ScrollView {
                            VStack(spacing: 20) {
                                Text("Deal of the Day")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("Next deal in: \(timeUntilNextDeal)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                VStack {
                                    Image(systemName: "star.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.orange)
                                        .padding(.bottom)
                                    
                                    Text(deal.description)
                                        .font(.title3)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                
                                Button(action: {
                                    addDealToCollection(deal)
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Save Deal")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                                }
                            }
                            .padding()
                        }
                    } else {
                        NoDealsView(timeUntilNextDeal: timeUntilNextDeal)
                    }
                }
            }
            .navigationTitle("Daily Deal")
            .onAppear {
                checkAndUpdateDeal()
                startTimer()
                checkIfDealSaved()
            }
        }
    }
    
    private func checkIfDealSaved() {
        isDealSaved = UserDefaults.standard.bool(forKey: dealSavedKey)
    }
    
    private func addDealToCollection(_ deal: Deal) {
        guard let username = userSession.username else { return }
        isLoading = true
        
        APIService.shared.addDealToUser(username: username, dealId: deal.id) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    isDealSaved = true
                    UserDefaults.standard.set(true, forKey: dealSavedKey)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Helper Views
    private struct DealSavedView: View {
        let timeUntilNextDeal: String
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Today's Deal Saved!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                Text("Come back tomorrow for a new deal")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Text("Next deal in: \(timeUntilNextDeal)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(40)
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
        }
    }
    
    private struct NoDealsView: View {
        let timeUntilNextDeal: String
        
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "tag.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("No Deals Available")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                Text("Next deal in: \(timeUntilNextDeal)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(40)
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
        }
    }
    
    private struct ErrorView: View {
        let message: String
        
        var body: some View {
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                Text(message)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding(40)
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
        }
    }
    
    private func startTimer() {
        // Update time remaining every minute
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateTimeUntilNextDeal()
        }
        updateTimeUntilNextDeal()
    }
    
    private func updateTimeUntilNextDeal() {
        let calendar = Calendar.current
        let now = Date()
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)
        
        if let hours = components.hour, let minutes = components.minute {
            timeUntilNextDeal = "\(hours)h \(minutes)m"
        }
    }
    
    private func checkAndUpdateDeal() {
        let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date ?? Date(timeIntervalSince1970: 0)
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(lastUpdate) {
            fetchNewDeal()
        } else {
            // Load cached deal
            if let dealData = UserDefaults.standard.data(forKey: currentDealKey),
               let deal = try? JSONDecoder().decode(Deal.self, from: dealData) {
                self.currentDeal = deal
            } else {
                fetchNewDeal()
            }
        }
    }
    
    private func fetchNewDeal() {
        guard let username = userSession.username else { return }
        isLoading = true
        errorMessage = nil
        
        APIService.shared.fetchRandomDeal(username: username) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let deal):
                    self.currentDeal = deal
                    // Cache the deal and update time
                    if let dealData = try? JSONEncoder().encode(deal) {
                        UserDefaults.standard.set(dealData, forKey: currentDealKey)
                        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Make Deal conform to Codable if not already done
    struct FeedView_Previews: PreviewProvider {
        static var previews: some View {
            FeedView()
                .environmentObject(UserSession())
        }
    }
}

import SwiftUI

struct Deal: Identifiable {
    let id: String
    let description: String
}

struct DealCard: View {
    let deal: Deal
    let onSwipe: (Bool) -> Void
    @State private var offset = CGSize.zero
    @State private var color: Color = .white
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 320, height: 420)
                .cornerRadius(16)
                .shadow(radius: 10)
            
            VStack {
                Text(deal.description)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Add more deal details here as needed
            }
        }
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    withAnimation {
                        color = offset.width > 0 ? .green : .red
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        let width = offset.width
                        if abs(width) > 100 {
                            offset = CGSize(width: width > 0 ? 500 : -500, height: 0)
                            onSwipe(width > 0)
                        } else {
                            offset = .zero
                            color = .white
                        }
                    }
                }
        )
    }
}

struct TradeView: View {
    @State private var deals: [Deal] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ZStack {
                        ForEach(deals.suffix(2).reversed()) { deal in
                            DealCard(deal: deal) { swiped in
                                handleSwipe(deal: deal, liked: swiped)
                                removeTopCard()
                            }
                        }
                    }
                    
                    if deals.isEmpty {
                        Text("No more deals available!")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                
                if isLoading {
                    ProgressView()
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Discover Deals")
            .onAppear {
                loadNewDeals()
            }
        }
    }
    
    private func loadNewDeals() {
        guard let username = userSession.username else { return }
        isLoading = true
        
        APIService.shared.fetchNewDeals(username: username) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let newDeals):
                    self.deals = newDeals
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func handleSwipe(deal: Deal, liked: Bool) {
        if liked {
            guard let username = userSession.username else { return }
            APIService.shared.addDealToUser(username: username, dealId: deal.id) { result in
                switch result {
                case .success:
                    print("Deal added successfully")
                case .failure(let error):
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func removeTopCard() {
        deals.removeLast()
        if deals.count < 2 {
            loadNewDeals()
        }
    }
}

struct TradeView_Previews: PreviewProvider {
    static var previews: some View {
        TradeView()
            .environmentObject(UserSession())
    }
}

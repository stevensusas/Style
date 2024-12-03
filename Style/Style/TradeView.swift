import SwiftUI

struct DealCard: View {
    let deal: Deal
    let onSwipe: (Bool) -> Void
    @State private var offset = CGSize.zero
    @State private var color: Color = .white
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 10)
            
            VStack(spacing: 20) {
                Text("New Deal!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(deal.description)
                    .font(.system(size: 24, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                
                Image(systemName: "tag.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color.orange)
                    .padding()
            }
            .padding()
        }
        .frame(width: 320, height: 420)
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
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                                .padding()
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding()
                        Spacer()
                    } else if deals.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "cart.badge.minus")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("No Deals Available")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            Text("Check back later for new deals!")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .padding(40)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding()
                        Spacer()
                    } else {
                        // Deals cards
                        ZStack {
                            ForEach(deals.suffix(2).reversed()) { deal in
                                DealCard(deal: deal) { swiped in
                                    handleSwipe(deal: deal, liked: swiped)
                                    removeTopCard()
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Swipe instructions
                        HStack(spacing: 40) {
                            VStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 30))
                                Text("Skip")
                                    .foregroundColor(.gray)
                            }
                            
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 30))
                                Text("Save")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.bottom)
                    }
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

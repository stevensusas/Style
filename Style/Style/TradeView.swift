import SwiftUI

struct TradeView: View {
    @State private var userBrand: String = "Ralph Lauren"
    @State private var userDeal: String = "$20 off any purchase"
    @State private var janeDeals: [(brand: String, deal: String, image: String)] = [
        ("Zara", "$10 off jeans", "zara"),
        ("Aerie", "$5 off tops", "aerie"),
        ("H&M", "$15 off orders above $50", "hm"),
        ("Nike", "$25 off sneakers", "nike")
    ]
    @State private var currentJaneDealIndex: Int = 0 // Keeps track of which deal is shown
    @State private var tradeWithUsername: String = "@janefits"
    @State private var tradeStatus: String = "" // Status message for Confirm or Cancel actions
    @State private var tradesLeft: Int = 3 // Limit of trades left
    @State private var tradeSuccessful: Bool = false // Toggle for showing the success view
    @State private var tradeCompleted: Bool = false // Prevent further trades after success

    var body: some View {
        VStack {
            if tradeSuccessful {
                // Trade Confirmed View
                VStack {
                    TradeCard(
                        brandImage: janeDeals[currentJaneDealIndex].image,
                        brandName: janeDeals[currentJaneDealIndex].brand,
                        dealDescription: janeDeals[currentJaneDealIndex].deal,
                        backgroundColor: .purple
                    )
                    .padding(.bottom, 20)

                    AvatarView(imageName: "user_avatar", username: "You")

                    Text("Congrats on your new deal! Come back tomorrow to make another trade.")
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                // Main View
                VStack {
                    // Title
                    Text("Confirm Trade?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)

                    Text("Confirm trade with \(tradeWithUsername)?")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)

                    Text("Trades Left: \(tradesLeft)")
                        .font(.subheadline)
                        .foregroundColor(tradesLeft > 0 ? .green : .red)
                        .padding(.bottom, 20)

                    // Trade Items Preview
                    HStack {
                        TradeCard(
                            brandImage: "ralph",
                            brandName: userBrand,
                            dealDescription: userDeal,
                            backgroundColor: .blue
                        )
                        TradeCard(
                            brandImage: janeDeals[currentJaneDealIndex].image,
                            brandName: janeDeals[currentJaneDealIndex].brand,
                            dealDescription: janeDeals[currentJaneDealIndex].deal,
                            backgroundColor: .purple
                        )
                    }
                    .padding()

                    Spacer()

                    // User Avatars
                    HStack {
                        AvatarView(imageName: "user_avatar", username: "You")
                        Spacer()
                        AvatarView(imageName: "jane_avatar", username: tradeWithUsername)
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    // Confirm & Cancel Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            cancelTrade()
                        }) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(tradesLeft > 0 && !tradeCompleted ? Color.red.opacity(0.8) : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(tradeCompleted || tradesLeft == 0) // Disable button if no trades left or trade completed

                        Button(action: {
                            confirmTrade()
                        }) {
                            Text("Confirm")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.green]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(tradeCompleted) // Disable button if trade is completed
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)

                    // Status Message
                    if !tradeStatus.isEmpty {
                        Text(tradeStatus)
                            .font(.headline)
                            .foregroundColor(tradeStatus.contains("confirmed") ? .green : .red)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.bottom, 60) // Extra padding to accommodate TabBar
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                TabBar(selectedTab: .trade)
            }
        }
    }

    // MARK: - Actions
    private func cancelTrade() {
        if tradesLeft > 0 {
            tradesLeft -= 1
            tradeStatus = "You denied the trade. \(tradesLeft) trades left."
            print(tradeStatus)
            currentJaneDealIndex = (currentJaneDealIndex + 1) % janeDeals.count
        } else {
            tradeStatus = "No trades left."
            print(tradeStatus)
        }
    }

    private func confirmTrade() {
        tradeSuccessful = true
        tradeCompleted = true // Mark the trade as completed
        tradeStatus = "Trade confirmed!"
        print(tradeStatus)
    }
}

// Trade Card View
struct TradeCard: View {
    let brandImage: String
    let brandName: String
    let dealDescription: String
    let backgroundColor: Color

    var body: some View {
        VStack {
            Image(brandImage)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .padding(.top, 10)

            Text(brandName)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 5)

            Text(dealDescription)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.top, 2)
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(width: 150, height: 200)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// Avatar View
struct AvatarView: View {
    let imageName: String
    let username: String

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())

            Text(username)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct TradeView_Previews: PreviewProvider {
    static var previews: some View {
        TradeView()
    }
}

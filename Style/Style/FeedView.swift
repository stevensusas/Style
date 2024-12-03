//
//  FeedView.swift
//  Style
//
//  Created by Stan Chen on 12/1/24.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var randomCoupon: Coupon?
    @State private var userCoupons: [Coupon] = []
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""

    var body: some View {
        VStack {
            // Random Coupon Section
            if let coupon = randomCoupon {
                VStack {
                    Text("Today's Deal")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    CouponCard(coupon: coupon)
                        .padding()

                    Button(action: {
                        claimCoupon(coupon: coupon)
                    }) {
                        Text("Claim Coupon")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(
                                gradient: Gradient(colors: [Color.pink, Color.orange]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            } else {
                ProgressView("Fetching a random coupon...")
                    .padding()
            }

            Divider()
                .padding()

            // User's Coupons Section
            VStack(alignment: .leading) {
                Text("Your Coupons")
                    .font(.headline)
                    .padding(.leading)

                if userCoupons.isEmpty {
                    Text("You have no coupons yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(userCoupons) { coupon in
                            CouponCard(coupon: coupon)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                        }
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            loadRandomCoupon()
            loadUserCoupons()
        }
        .navigationBarTitle("Feed", displayMode: .inline)
        .alert(isPresented: .constant(!errorMessage.isEmpty || !successMessage.isEmpty)) {
            Alert(
                title: Text(errorMessage.isEmpty ? "Success" : "Error"),
                message: Text(errorMessage.isEmpty ? successMessage : errorMessage),
                dismissButton: .default(Text("OK"), action: {
                    errorMessage = ""
                    successMessage = ""
                })
            )
        }
    }

    // MARK: - Helper Functions

    private func loadRandomCoupon() {
        APIService.shared.fetchRandomCoupon { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coupon):
                    self.randomCoupon = coupon
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadUserCoupons() {
        guard let username = userSession.username else {
            self.errorMessage = "User not logged in."
            return
        }
        APIService.shared.fetchUserDiscounts(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coupons):
                    self.userCoupons = coupons
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func claimCoupon(coupon: Coupon) {
        guard let username = userSession.username else {
            self.errorMessage = "User not logged in."
            return
        }
        APIService.shared.claimCoupon(username: username, couponId: coupon.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.successMessage = message
                    self.loadUserCoupons() // Reload user's coupons
                    self.loadRandomCoupon() // Fetch new random coupon
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    
    struct CouponCard: View {
        let coupon: Coupon

        var body: some View {
            VStack {
                // Coupon Image
                AsyncImage(url: URL(string: coupon.imageURL)) { image in
                    image.resizable()
                         .scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 100)
                .cornerRadius(10)
                .padding(.top, 10)

                // Coupon Details
                Text(coupon.brand)
                    .font(.headline)
                    .padding(.top, 5)

                Text(coupon.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }

    // MARK: - Preview

    struct FeedView_Previews: PreviewProvider {
        static var previews: some View {
            FeedView()
                .environmentObject(UserSession())
        }
    }
}

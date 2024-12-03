//
//  MainView.swift
//  Style
//
//  Created by Stan Chen on 12/3/24.
//
import SwiftUI

struct MainView: View {
    @State private var selectedTab: TabBar.Tab = .feed // Default tab
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        VStack(spacing: 0) {
            // Content View
            Group {
                switch selectedTab {
                case .feed:
                    FeedView()
                        .environmentObject(userSession)
                case .trade:
                    TradeView()
                        .environmentObject(userSession)
                case .profile:
                    ProfileView()
                        .environmentObject(userSession)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab Bar
            TabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom) // Ensures TabBar isn't overlapped
    }
}

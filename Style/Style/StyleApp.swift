//
//  StyleApp.swift
//  Style
//
//  Created by Steven Su on 12/1/24.
//

import SwiftUI

@main
struct StyleApp: App {
    @StateObject private var userSession = UserSession()
    @State private var selectedTab: Tab = .profile
    
    enum Tab {
        case friends, feed, trade, profile
    }
    
    var body: some Scene {
        WindowGroup {
            if userSession.isAuthenticated {
                TabView(selection: $selectedTab) {
                    Text("Friends View")
                        .tabItem {
                            Image(systemName: "person.2.fill")
                            Text("Friends")
                        }
                        .tag(Tab.friends)
                    
                    Text("Feed View")
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Feed")
                        }
                        .tag(Tab.feed)
                    
                    TradeView()
                        .tabItem {
                            Image(systemName: "cart.fill")
                            Text("Trade")
                        }
                        .tag(Tab.trade)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(Tab.profile)
                }
                .environmentObject(userSession)
            } else {
                AuthView()
                    .environmentObject(userSession)
            }
        }
    }
}

//
//  StyleApp.swift
//  Style
//
//  Created by Steven Su on 12/1/24.
//

import SwiftUI

@main
struct StyleApp: App {
    @StateObject var userSession = UserSession()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
        }
    }
}

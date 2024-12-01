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
    
    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(userSession)
        }
    }
}

//
//  ContentView.swift
//  Style
//
//  Created by Stan Chen on 12/3/24.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        Group {
            if userSession.isAuthenticated {
                MainView()
                    .environmentObject(userSession)
            } else {
                AuthView()
                    .environmentObject(userSession)
            }
        }
    }
}

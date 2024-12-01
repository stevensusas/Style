import SwiftUI
import Combine

class UserSession: ObservableObject {
    @Published var username: String? = nil
    @Published var isAuthenticated: Bool = false
    
    func login(username: String) {
        self.username = username
        self.isAuthenticated = true
    }
    
    func logout() {
        self.username = nil
        self.isAuthenticated = false
    }
}

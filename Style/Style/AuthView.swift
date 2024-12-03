import SwiftUI

struct AuthView: View {
    @EnvironmentObject var userSession: UserSession // Access UserSession as a shared state
    @State private var isSignUp: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    @State private var isLoggedIn: Bool = false // Tracks if login was successful

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Foreground Content
                VStack {
                    // App Title
                    Text("Style")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.top, 50)

                    Spacer()

                    // Picker Toggle
                    Picker("", selection: $isSignUp) {
                        Text("Login").tag(false)
                        Text("Sign Up").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Form Fields
                    VStack(spacing: 15) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    // Submit Button
                    Button(action: handleSubmit) {
                        Text(isSignUp ? "Sign Up" : "Login")
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
                    .padding(.top, 20)

                    // Error or Success Messages
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                    }

                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                            .padding(.top, 10)
                    }

                    Spacer()

                    // Footer
                    Text("By signing up, you agree to our Terms and Privacy Policy.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }

                // Navigate to ProfileView when logged in
                NavigationLink(
                    destination: ProfileView().environmentObject(userSession),
                    isActive: $isLoggedIn
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                // Clear messages on view load
                errorMessage = ""
                successMessage = ""
            }
        }
    }

    // Handle form submission
    func handleSubmit() {
        if isSignUp {
            // Handle Sign Up
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match"
                return
            }

            APIService.shared.signUp(username: username, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        successMessage = message
                        errorMessage = ""
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        successMessage = ""
                    }
                }
            }
        } else {
            // Handle Login
            APIService.shared.logIn(username: username, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let userDetails):
                        successMessage = "Login successful!"
                        errorMessage = ""
                        userSession.login(username: userDetails["username"] as! String) // Update UserSession
                        isLoggedIn = true // Trigger navigation to ProfileView
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        successMessage = ""
                    }
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(UserSession())
    }
}

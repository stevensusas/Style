import SwiftUI

struct AuthView: View {
    @State private var isSignUp: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        ZStack {
            // Background Gradient - Lighter Colors
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemTeal), Color(.systemBlue).opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // App Logo or Title
                Text("VogueVault")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 60)

                Spacer()

                // Form Toggle
                HStack {
                    Button(action: {
                        withAnimation {
                            isSignUp = false
                        }
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .foregroundColor(isSignUp ? .gray : .white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isSignUp ? Color.clear : Color.blue.opacity(0.8))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        withAnimation {
                            isSignUp = true
                        }
                    }) {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(isSignUp ? .white : .gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isSignUp ? Color.blue.opacity(0.8) : Color.clear)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // Form Fields
                VStack(spacing: 20) {
                    // Username Field (Visible in Both Login and Sign Up)
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    // Password Field (Visible in Both Login and Sign Up)
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)

                    // Confirm Password Field (Visible Only in Sign Up Mode)
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
                Button(action: {
                    if isSignUp {
                        // Replace with actual validation or API call
                        print("Sign Up with: \(username), \(password), \(confirmPassword)")
                    } else {
                        // Replace with actual validation or API call
                        print("Login with: \(username), \(password)")
                    }
                }) {
                    Text(isSignUp ? "Sign Up" : "Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)

                Spacer()

                // Footer
                Text("By signing up, you agree to our Terms and Privacy Policy.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

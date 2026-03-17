import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var showRegister: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("StudyFlowAI")
                .font(.largeTitle.bold())

            TextField("Email", text: $authViewModel.email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                Task { await authViewModel.signIn() }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Create account") {
                showRegister = true
            }
        }
        .padding()
    }
}

#Preview {
    LoginView(showRegister: .constant(false))
        .environmentObject(AuthViewModel.previewUnauthenticated)
}

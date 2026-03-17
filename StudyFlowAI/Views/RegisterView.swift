import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Binding var showRegister: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Create Account")
                    .font(.largeTitle.bold())

                TextField("Name", text: $authViewModel.name)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $authViewModel.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $authViewModel.password)
                    .textFieldStyle(.roundedBorder)

                Picker("Study Style", selection: $authViewModel.selectedStudyStyle) {
                    ForEach(StudyStyle.allCases) { style in
                        Text(style.displayName).tag(style)
                    }
                }
                .pickerStyle(.menu)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button {
                    Task { await authViewModel.register() }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Back to sign in") {
                    showRegister = false
                }
            }
            .padding()
        }
    }
}

#Preview {
    RegisterView(showRegister: .constant(true))
        .environmentObject(AuthViewModel.previewUnauthenticated)
}

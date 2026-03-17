import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var name: String = ""
    @Published var selectedStudyStyle: StudyStyle = .mixed
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let authService: AuthService
    private let subscriptionService: SubscriptionService

    var currentUser: User? { authService.currentUser }
    var isAuthenticated: Bool { authService.isAuthenticated }

    init(authService: AuthService, subscriptionService: SubscriptionService) {
        self.authService = authService
        self.subscriptionService = subscriptionService
    }

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signIn(email: email, password: password)
            await subscriptionService.refreshSubscription(for: authService.currentUser)
            clearInputs()
            errorMessage = nil
        } catch {
            errorMessage = "Unable to sign in right now."
        }
    }

    func register() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please complete all fields."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.register(
                name: name,
                email: email,
                password: password,
                studyStyle: selectedStudyStyle
            )
            await subscriptionService.refreshSubscription(for: authService.currentUser)
            clearInputs()
            errorMessage = nil
        } catch {
            errorMessage = "Unable to create an account right now."
        }
    }

    func signOut() {
        authService.signOut()
        Task {
            await subscriptionService.refreshSubscription(for: nil)
        }
    }

    private func clearInputs() {
        email = ""
        password = ""
        name = ""
    }
}

extension AuthViewModel {
    static var previewAuthenticated: AuthViewModel {
        let authService = AuthService()
        authService.loadPreviewSession()
        let subscriptionService = SubscriptionService()
        subscriptionService.loadPreviewSubscription()
        return AuthViewModel(authService: authService, subscriptionService: subscriptionService)
    }

    static var previewUnauthenticated: AuthViewModel {
        AuthViewModel(authService: AuthService(), subscriptionService: SubscriptionService())
    }
}

import Foundation

@MainActor
public final class AuthViewModel {
    private let authService: AuthService

    public private(set) var currentUser: AuthUser?
    public private(set) var isLoading = false
    public private(set) var alertMessage: String?

    public init(authService: AuthService) {
        self.authService = authService
    }

    public func hydrateCurrentUser() async {
        isLoading = true
        defer { isLoading = false }

        do {
            currentUser = try await authService.currentUser()
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    public func signUp(email: String, password: String) async {
        await performAuthAction {
            try await authService.signUp(email: email, password: password)
        }
    }

    public func signIn(email: String, password: String) async {
        await performAuthAction {
            try await authService.signIn(email: email, password: password)
        }
    }

    public func signOut() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signOut()
            currentUser = nil
            alertMessage = nil
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    public func resetPassword(email: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.resetPassword(email: email)
            alertMessage = "Password reset email sent."
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func performAuthAction(_ action: () async throws -> AuthUser) async {
        isLoading = true
        defer { isLoading = false }

        do {
            currentUser = try await action()
            alertMessage = nil
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }
}

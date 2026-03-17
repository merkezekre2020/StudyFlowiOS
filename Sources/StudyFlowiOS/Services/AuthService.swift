import Foundation
import Supabase

public struct AuthUser: Equatable {
    public let id: UUID
    public let email: String?
}

public protocol AuthService {
    func signUp(email: String, password: String) async throws -> AuthUser
    func signIn(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
    func resetPassword(email: String) async throws
    func currentUser() async throws -> AuthUser?
}

public final class SupabaseAuthService: AuthService {
    private let provider: SupabaseClientProviding

    public init(provider: SupabaseClientProviding) {
        self.provider = provider
    }

    public func signUp(email: String, password: String) async throws -> AuthUser {
        do {
            let response = try await provider.client.auth.signUp(email: email, password: password)
            return AuthUser(id: response.user.id, email: response.user.email)
        } catch {
            throw AppError.map(error)
        }
    }

    public func signIn(email: String, password: String) async throws -> AuthUser {
        do {
            let session = try await provider.client.auth.signIn(email: email, password: password)
            return AuthUser(id: session.user.id, email: session.user.email)
        } catch {
            throw AppError.map(error)
        }
    }

    public func signOut() async throws {
        do {
            try await provider.client.auth.signOut()
        } catch {
            throw AppError.map(error)
        }
    }

    public func resetPassword(email: String) async throws {
        do {
            try await provider.client.auth.resetPasswordForEmail(email)
        } catch {
            throw AppError.map(error)
        }
    }

    public func currentUser() async throws -> AuthUser? {
        do {
            let session = try await provider.client.auth.session
            return AuthUser(id: session.user.id, email: session.user.email)
        } catch {
            return nil
        }
    }
}

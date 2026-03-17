import Foundation
import Supabase

public protocol ProfileRepository {
    func fetchProfile(userID: UUID) async throws -> UserProfile?
    func upsertProfile(_ profile: UserProfile) async throws -> UserProfile
    func deleteProfile(userID: UUID) async throws
}

public final class SupabaseProfileRepository: ProfileRepository {
    private let provider: SupabaseClientProviding

    public init(provider: SupabaseClientProviding) {
        self.provider = provider
    }

    public func fetchProfile(userID: UUID) async throws -> UserProfile? {
        do {
            return try await provider.client
                .from("users")
                .select()
                .eq("user_id", value: userID)
                .single()
                .execute()
                .value
        } catch {
            if (error as NSError).localizedDescription.lowercased().contains("results contain 0 rows") {
                return nil
            }
            throw AppError.map(error)
        }
    }

    public func upsertProfile(_ profile: UserProfile) async throws -> UserProfile {
        do {
            return try await provider.client
                .from("users")
                .upsert(profile)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    public func deleteProfile(userID: UUID) async throws {
        do {
            _ = try await provider.client
                .from("users")
                .delete()
                .eq("user_id", value: userID)
                .execute()
        } catch {
            throw AppError.map(error)
        }
    }
}

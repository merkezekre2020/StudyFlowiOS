import Foundation
import Supabase

public protocol SubjectRepository {
    func listSubjects(userID: UUID) async throws -> [Subject]
    func createSubject(_ subject: Subject) async throws -> Subject
    func updateSubject(_ subject: Subject) async throws -> Subject
    func deleteSubject(subjectID: UUID, userID: UUID) async throws
}

public final class SupabaseSubjectRepository: SubjectRepository {
    private let provider: SupabaseClientProviding

    public init(provider: SupabaseClientProviding) {
        self.provider = provider
    }

    public func listSubjects(userID: UUID) async throws -> [Subject] {
        do {
            return try await provider.client
                .from("subjects")
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    public func createSubject(_ subject: Subject) async throws -> Subject {
        do {
            return try await provider.client
                .from("subjects")
                .insert(subject)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    public func updateSubject(_ subject: Subject) async throws -> Subject {
        do {
            return try await provider.client
                .from("subjects")
                .update(subject)
                .eq("id", value: subject.id)
                .eq("user_id", value: subject.userID)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    public func deleteSubject(subjectID: UUID, userID: UUID) async throws {
        do {
            _ = try await provider.client
                .from("subjects")
                .delete()
                .eq("id", value: subjectID)
                .eq("user_id", value: userID)
                .execute()
        } catch {
            throw AppError.map(error)
        }
    }
}

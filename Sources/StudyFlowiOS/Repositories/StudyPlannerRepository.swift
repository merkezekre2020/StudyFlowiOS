import Foundation
import Supabase

public protocol StudyPlannerRepository {
    func listPlans(userID: UUID) async throws -> [StudyPlan]
    func createPlan(_ plan: StudyPlan) async throws -> StudyPlan
    func updatePlan(_ plan: StudyPlan) async throws -> StudyPlan
    func deletePlan(id: UUID, userID: UUID) async throws

    func listTasks(planID: UUID, userID: UUID) async throws -> [StudyTask]
    func createTask(_ task: StudyTask) async throws -> StudyTask
    func updateTask(_ task: StudyTask) async throws -> StudyTask
    func deleteTask(id: UUID, userID: UUID) async throws

    func listProgressLogs(userID: UUID, planID: UUID?) async throws -> [ProgressLog]
    func writeProgressLog(_ log: ProgressLog) async throws -> ProgressLog
}

public final class SupabaseStudyPlannerRepository: StudyPlannerRepository {
    private let provider: SupabaseClientProviding

    public init(provider: SupabaseClientProviding) {
        self.provider = provider
    }

    public func listPlans(userID: UUID) async throws -> [StudyPlan] {
        try await queryList(table: "study_plans", userID: userID)
    }

    public func createPlan(_ plan: StudyPlan) async throws -> StudyPlan {
        try await insert(table: "study_plans", row: plan)
    }

    public func updatePlan(_ plan: StudyPlan) async throws -> StudyPlan {
        try await update(table: "study_plans", row: plan, id: plan.id, userID: plan.userID)
    }

    public func deletePlan(id: UUID, userID: UUID) async throws {
        try await delete(table: "study_plans", id: id, userID: userID)
    }

    public func listTasks(planID: UUID, userID: UUID) async throws -> [StudyTask] {
        do {
            return try await provider.client
                .from("study_tasks")
                .select()
                .eq("user_id", value: userID)
                .eq("plan_id", value: planID)
                .order("due_at", ascending: true)
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    public func createTask(_ task: StudyTask) async throws -> StudyTask {
        try await insert(table: "study_tasks", row: task)
    }

    public func updateTask(_ task: StudyTask) async throws -> StudyTask {
        try await update(table: "study_tasks", row: task, id: task.id, userID: task.userID)
    }

    public func deleteTask(id: UUID, userID: UUID) async throws {
        try await delete(table: "study_tasks", id: id, userID: userID)
    }

    public func listProgressLogs(userID: UUID, planID: UUID?) async throws -> [ProgressLog] {
        do {
            var query = provider.client
                .from("progress_logs")
                .select()
                .eq("user_id", value: userID)
            if let planID {
                query = query.eq("plan_id", value: planID)
            }
            return try await query
                .order("logged_at", ascending: false)
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    public func writeProgressLog(_ log: ProgressLog) async throws -> ProgressLog {
        try await insert(table: "progress_logs", row: log)
    }

    private func queryList<T: Decodable>(table: String, userID: UUID) async throws -> [T] {
        do {
            return try await provider.client
                .from(table)
                .select()
                .eq("user_id", value: userID)
                .order("created_at", ascending: false)
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    private func insert<T: Encodable, U: Decodable>(table: String, row: T) async throws -> U {
        do {
            return try await provider.client
                .from(table)
                .insert(row)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    private func update<T: Encodable, U: Decodable>(table: String, row: T, id: UUID, userID: UUID) async throws -> U {
        do {
            return try await provider.client
                .from(table)
                .update(row)
                .eq("id", value: id)
                .eq("user_id", value: userID)
                .select()
                .single()
                .execute()
                .value
        } catch {
            throw AppError.map(error)
        }
    }

    private func delete(table: String, id: UUID, userID: UUID) async throws {
        do {
            _ = try await provider.client
                .from(table)
                .delete()
                .eq("id", value: id)
                .eq("user_id", value: userID)
                .execute()
        } catch {
            throw AppError.map(error)
        }
    }
}

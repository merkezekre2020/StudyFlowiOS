import Foundation

@MainActor
public final class StudyPlannerViewModel {
    private let repository: StudyPlannerRepository

    public private(set) var plans: [StudyPlan] = []
    public private(set) var tasksByPlan: [UUID: [StudyTask]] = [:]
    public private(set) var progressLogs: [ProgressLog] = []
    public private(set) var isLoading = false
    public private(set) var alertMessage: String?

    public init(repository: StudyPlannerRepository) {
        self.repository = repository
    }

    public func loadPlans(userID: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            plans = try await repository.listPlans(userID: userID)
            alertMessage = nil
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    public func loadTasks(planID: UUID, userID: UUID) async {
        isLoading = true
        defer { isLoading = false }

        do {
            tasksByPlan[planID] = try await repository.listTasks(planID: planID, userID: userID)
            alertMessage = nil
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }

    public func loadProgress(userID: UUID, planID: UUID? = nil) async {
        isLoading = true
        defer { isLoading = false }

        do {
            progressLogs = try await repository.listProgressLogs(userID: userID, planID: planID)
            alertMessage = nil
        } catch {
            alertMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }
}

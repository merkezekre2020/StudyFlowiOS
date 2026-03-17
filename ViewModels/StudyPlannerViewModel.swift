import Foundation

struct StudyAnalytics {
    var completedSessions: Int = 0
    var weeklyHours: Double = 0
    var subjectProgress: [UUID: Double] = [:]
}

@MainActor
final class StudyPlannerViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var studyDays: [StudyDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var analytics: StudyAnalytics = .init()

    private let apiService: APIService
    private var currentUser: User?

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func bootstrap(for user: User?) async {
        currentUser = user
        guard let user else {
            subjects = []
            studyDays = []
            analytics = .init()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            subjects = try await apiService.fetchSubjects(for: user)
            errorMessage = nil
            await generatePlan()
        } catch {
            errorMessage = "Could not load your study data."
        }
    }

    func generatePlan() async {
        guard let currentUser else {
            errorMessage = "Please sign in to generate a study plan."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let generated = try await apiService.generateStudyPlan(profile: currentUser, subjects: subjects)
            studyDays = generated
            try await apiService.persistStudyPlan(generated, user: currentUser, subjects: subjects)
            errorMessage = nil
            recomputeAnalytics()
        } catch {
            errorMessage = "Unable to generate your plan. \(error.localizedDescription)"
        }
    }

    func addSubject(name: String, difficulty: Difficulty) {
        guard !name.isEmpty else { return }
        let newSubject = Subject(name: name, difficulty: difficulty)
        subjects.append(newSubject)
    }

    func toggleTask(dayID: UUID, taskID: UUID) {
        guard let dayIndex = studyDays.firstIndex(where: { $0.id == dayID }),
              let taskIndex = studyDays[dayIndex].tasks.firstIndex(where: { $0.id == taskID }) else {
            return
        }

        studyDays[dayIndex].tasks[taskIndex].isCompleted.toggle()
        let task = studyDays[dayIndex].tasks[taskIndex]

        Task {
            await logProgress(for: task)
        }
        recomputeAnalytics()
    }

    func color(for subjectID: UUID) -> String {
        subjects.first(where: { $0.id == subjectID })?.colorHex ?? "#64748B"
    }

    func subjectName(for subjectID: UUID) -> String {
        subjects.first(where: { $0.id == subjectID })?.name ?? "General"
    }

    private func logProgress(for task: StudyTask) async {
        guard let user = currentUser else { return }
        do {
            let minutes = task.isCompleted ? task.durationMinutes : 0
            let note = task.isCompleted ? "Task completed" : "Task marked incomplete"
            try await apiService.writeProgressLog(userID: user.id, taskID: task.id, planID: nil, minutesStudied: minutes, note: note)
            errorMessage = nil
        } catch {
            errorMessage = "Progress sync failed: \(error.localizedDescription)"
        }
    }

    private func recomputeAnalytics() {
        let allTasks = studyDays.flatMap(\.tasks)
        let completed = allTasks.filter(\.isCompleted)
        let completedMinutes = completed.reduce(0) { $0 + $1.durationMinutes }

        let grouped = Dictionary(grouping: allTasks, by: \.subjectID)
        var subjectProgress: [UUID: Double] = [:]
        for (subjectID, tasks) in grouped {
            let done = tasks.filter(\.isCompleted).count
            let pct = tasks.isEmpty ? 0 : (Double(done) / Double(tasks.count)) * 100
            subjectProgress[subjectID] = pct
        }

        analytics = StudyAnalytics(
            completedSessions: completed.count,
            weeklyHours: Double(completedMinutes) / 60.0,
            subjectProgress: subjectProgress
        )
    }
}

extension StudyPlannerViewModel {
    static var preview: StudyPlannerViewModel {
        let vm = StudyPlannerViewModel()
        let subjects = APIService.mockSubjects
        vm.subjects = subjects
        vm.studyDays = [
            StudyDay(
                date: .now,
                tasks: [
                    StudyTask(subjectID: subjects[0].id, title: "Algebra Review", details: "Practice equations", durationMinutes: 45),
                    StudyTask(subjectID: subjects[1].id, title: "Cell Structure", details: "Read chapter 4", durationMinutes: 35, isCompleted: true)
                ]
            )
        ]
        vm.analytics = StudyAnalytics(
            completedSessions: 1,
            weeklyHours: 0.58,
            subjectProgress: [subjects[1].id: 100]
        )
        return vm
    }
}

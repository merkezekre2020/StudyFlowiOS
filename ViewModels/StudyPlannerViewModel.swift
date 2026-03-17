import Foundation

@MainActor
final class StudyPlannerViewModel: ObservableObject {
    @Published var subjects: [Subject] = []
    @Published var studyDays: [StudyDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }

    func bootstrap(for user: User?) async {
        guard let user else {
            subjects = []
            studyDays = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedSubjects = try await apiService.fetchSubjects(for: user)
            subjects = fetchedSubjects
            studyDays = try await apiService.generateStudyPlan(user: user, subjects: fetchedSubjects)
            errorMessage = nil
        } catch {
            errorMessage = "Could not load your study data."
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
        return vm
    }
}

import Foundation

actor APIService {
    func fetchSubjects(for user: User) async throws -> [Subject] {
        _ = user
        try await Task.sleep(for: .milliseconds(250))
        return Self.mockSubjects
    }

    func generateStudyPlan(user: User, subjects: [Subject]) async throws -> [StudyDay] {
        _ = user
        try await Task.sleep(for: .milliseconds(350))

        let activeSubjects = subjects.isEmpty ? Self.mockSubjects : subjects
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<5).map { offset in
            let dayDate = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            let tasks = activeSubjects.prefix(3).map { subject in
                StudyTask(
                    subjectID: subject.id,
                    title: "\(subject.name) Focus Session",
                    details: "Review core concepts and complete a quick recap quiz.",
                    durationMinutes: subject.weeklyHours * 10 + (offset * 5)
                )
            }
            return StudyDay(date: dayDate, tasks: tasks)
        }
    }

    static let mockSubjects: [Subject] = [
        Subject(name: "Mathematics", colorHex: "#3B82F6", difficulty: .hard, weeklyHours: 6),
        Subject(name: "Biology", colorHex: "#10B981", difficulty: .medium, weeklyHours: 4),
        Subject(name: "History", colorHex: "#F59E0B", difficulty: .easy, weeklyHours: 3)
    ]
}

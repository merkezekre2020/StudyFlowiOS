import Foundation

struct StudyDay: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var tasks: [StudyTask]

    init(id: UUID = UUID(), date: Date, tasks: [StudyTask]) {
        self.id = id
        self.date = date
        self.tasks = tasks
    }

    var totalMinutes: Int {
        tasks.reduce(0) { $0 + $1.durationMinutes }
    }
}

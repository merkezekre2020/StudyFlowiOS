import Foundation

struct StudyTask: Identifiable, Codable, Equatable {
    let id: UUID
    var subjectID: UUID
    var title: String
    var details: String
    var durationMinutes: Int
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        subjectID: UUID,
        title: String,
        details: String,
        durationMinutes: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.subjectID = subjectID
        self.title = title
        self.details = details
        self.durationMinutes = durationMinutes
        self.isCompleted = isCompleted
    }
}

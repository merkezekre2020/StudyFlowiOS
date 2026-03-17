import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var studyStyle: StudyStyle
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        studyStyle: StudyStyle = .mixed,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.studyStyle = studyStyle
        self.createdAt = createdAt
    }
}

enum StudyStyle: String, Codable, CaseIterable, Identifiable {
    case visual
    case auditory
    case readingWriting
    case kinesthetic
    case mixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .visual: return "Visual"
        case .auditory: return "Auditory"
        case .readingWriting: return "Reading/Writing"
        case .kinesthetic: return "Kinesthetic"
        case .mixed: return "Mixed"
        }
    }
}

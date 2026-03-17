import Foundation

public struct UserProfile: Codable, Identifiable, Equatable {
    public let id: UUID
    public var email: String
    public var displayName: String?
    public var timezone: String?
    public var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email
        case displayName = "display_name"
        case timezone
        case createdAt = "created_at"
    }

    public init(id: UUID, email: String, displayName: String? = nil, timezone: String? = nil, createdAt: Date? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.timezone = timezone
        self.createdAt = createdAt
    }
}

public struct Subject: Codable, Identifiable, Equatable {
    public let id: UUID
    public let userID: UUID
    public var title: String
    public var colorHex: String?
    public var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case title
        case colorHex = "color_hex"
        case createdAt = "created_at"
    }
}

public struct StudyPlan: Codable, Identifiable, Equatable {
    public let id: UUID
    public let userID: UUID
    public let subjectID: UUID
    public var title: String
    public var objective: String?
    public var startsAt: Date?
    public var endsAt: Date?
    public var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case subjectID = "subject_id"
        case title
        case objective
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case createdAt = "created_at"
    }
}

public struct StudyTask: Codable, Identifiable, Equatable {
    public let id: UUID
    public let userID: UUID
    public let planID: UUID
    public var title: String
    public var notes: String?
    public var dueAt: Date?
    public var isCompleted: Bool
    public var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case planID = "plan_id"
        case title
        case notes
        case dueAt = "due_at"
        case isCompleted = "is_completed"
        case createdAt = "created_at"
    }
}

public struct ProgressLog: Codable, Identifiable, Equatable {
    public let id: UUID
    public let userID: UUID
    public let taskID: UUID?
    public let planID: UUID?
    public var minutesStudied: Int
    public var confidence: Int?
    public var notes: String?
    public var loggedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case taskID = "task_id"
        case planID = "plan_id"
        case minutesStudied = "minutes_studied"
        case confidence
        case notes
        case loggedAt = "logged_at"
    }
}

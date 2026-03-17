import Foundation

struct Subject: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String
    var difficulty: Difficulty
    var weeklyHours: Int

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#4F46E5",
        difficulty: Difficulty = .medium,
        weeklyHours: Int = 4
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.difficulty = difficulty
        self.weeklyHours = weeklyHours
    }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

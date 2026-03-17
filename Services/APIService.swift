import Foundation

actor APIService {
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init() {
        jsonDecoder = JSONDecoder()
        jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
    }

    func fetchSubjects(for user: User) async throws -> [Subject] {
        _ = user
        try await Task.sleep(for: .milliseconds(250))
        return Self.mockSubjects
    }

    func generateStudyPlan(user: User, subjects: [Subject]) async throws -> [StudyDay] {
        try await generateStudyPlan(profile: user, subjects: subjects)
    }

    func generateStudyPlan(profile: User, subjects: [Subject]) async throws -> [StudyDay] {
        let activeSubjects = subjects.isEmpty ? Self.mockSubjects : subjects
        let payload = buildPlanPayload(profile: profile, subjects: activeSubjects)

        for _ in 0..<2 {
            let raw = try await requestOpenAIPlan(payload: payload)
            if let plan = tryParsePlan(from: raw, subjects: activeSubjects) {
                return plan
            }
        }

        throw APIServiceError.invalidPlanJSON
    }

    func persistStudyPlan(_ days: [StudyDay], user: User, subjects: [Subject]) async throws {
        let subjectMap = Dictionary(uniqueKeysWithValues: subjects.map { ($0.id, $0) })
        for day in days {
            for task in day.tasks {
                let plan = try await insert(table: "study_plans", payload: StudyPlanRow(
                    userID: user.id,
                    subjectID: task.subjectID,
                    title: task.title,
                    objective: task.details,
                    startsAt: day.date,
                    endsAt: day.date
                )) as PersistedPlanRow

                _ = try await insert(table: "study_tasks", payload: StudyTaskRow(
                    userID: user.id,
                    planID: plan.id,
                    title: task.title,
                    notes: "\(subjectMap[task.subjectID]?.name ?? "Subject") • \(task.details)",
                    dueAt: day.date,
                    isCompleted: task.isCompleted
                )) as PersistedTaskRow
            }
        }
    }

    func writeProgressLog(userID: UUID, taskID: UUID?, planID: UUID?, minutesStudied: Int, note: String) async throws {
        _ = try await insert(table: "progress_logs", payload: ProgressLogRow(
            userID: userID,
            taskID: taskID,
            planID: planID,
            minutesStudied: minutesStudied,
            confidence: nil,
            notes: note,
            loggedAt: Date()
        )) as PersistedProgressLogRow
    }

    private func buildPlanPayload(profile: User, subjects: [Subject]) -> String {
        let body: [String: Any] = [
            "student_profile": [
                "name": profile.name,
                "study_style": profile.studyStyle.rawValue,
                "daily_hours": 2,
                "weekly_goals": "Maintain consistency while improving weak subjects"
            ],
            "subjects": subjects.map {
                [
                    "id": $0.id.uuidString,
                    "name": $0.name,
                    "exam_date": NSNull(),
                    "difficulty": $0.difficulty.rawValue,
                    "daily_hours": max(1, $0.weeklyHours / 5),
                    "weekly_goals": "Complete \($0.weeklyHours) planned hours"
                ] as [String: Any]
            }
        ]
        let data = try? JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted])
        return String(data: data ?? Data(), encoding: .utf8) ?? "{}"
    }

    private func requestOpenAIPlan(payload: String) async throws -> String {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !key.isEmpty else {
            throw APIServiceError.missingOpenAIKey
        }

        let requestBody = ChatRequest(
            model: "gpt-4.1-mini",
            messages: [
                .init(role: "system", content: "Return JSON only. No markdown. Output schema: {\"days\":[{\"date\":\"YYYY-MM-DD\",\"tasks\":[{\"subject\":\"string\",\"subject_id\":\"uuid-or-null\",\"title\":\"string\",\"details\":\"string\",\"duration_minutes\":30}]}]}"),
                .init(role: "user", content: payload)
            ],
            responseFormat: .init(type: "json_object")
        )

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.httpBody = try jsonEncoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw APIServiceError.apiFailure(String(data: data, encoding: .utf8) ?? "OpenAI request failed")
        }

        let decoded = try jsonDecoder.decode(ChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
            throw APIServiceError.emptyResponse
        }
        return content
    }

    private func tryParsePlan(from raw: String, subjects: [Subject]) -> [StudyDay]? {
        if let parsed = try? decodePlan(from: raw, subjects: subjects) {
            return parsed
        }
        guard let object = extractFirstJSONObject(from: raw) else { return nil }
        return try? decodePlan(from: object, subjects: subjects)
    }

    private func decodePlan(from raw: String, subjects: [Subject]) throws -> [StudyDay] {
        let plan = try jsonDecoder.decode(GeneratedPlan.self, from: Data(raw.utf8))
        let subjectByID = Dictionary(uniqueKeysWithValues: subjects.map { ($0.id.uuidString.lowercased(), $0.id) })
        let subjectByName = Dictionary(uniqueKeysWithValues: subjects.map { ($0.name.lowercased(), $0.id) })
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        return plan.days.compactMap { day in
            guard let date = formatter.date(from: day.date) else { return nil }
            let tasks = day.tasks.map { task in
                let subjectID = task.subjectID.flatMap { subjectByID[$0.lowercased()] }
                    ?? subjectByName[task.subject.lowercased()]
                    ?? subjects.first?.id
                    ?? UUID()
                return StudyTask(subjectID: subjectID, title: task.title, details: task.details, durationMinutes: max(10, task.durationMinutes))
            }
            return StudyDay(date: date, tasks: tasks)
        }
    }

    private func extractFirstJSONObject(from text: String) -> String? {
        guard let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") else { return nil }
        return String(text[start...end])
    }

    private func insert<T: Encodable, U: Decodable>(table: String, payload: T) async throws -> U {
        guard let baseURLString = ProcessInfo.processInfo.environment["SUPABASE_URL"],
              let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"],
              let url = URL(string: "\(baseURLString)/rest/v1/\(table)?select=*") else {
            throw APIServiceError.missingSupabaseConfig
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        request.httpBody = try jsonEncoder.encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw APIServiceError.apiFailure(String(data: data, encoding: .utf8) ?? "Supabase request failed")
        }

        let rows = try jsonDecoder.decode([U].self, from: data)
        guard let first = rows.first else { throw APIServiceError.emptyResponse }
        return first
    }

    static let mockSubjects: [Subject] = [
        Subject(name: "Mathematics", colorHex: "#3B82F6", difficulty: .hard, weeklyHours: 6),
        Subject(name: "Biology", colorHex: "#10B981", difficulty: .medium, weeklyHours: 4),
        Subject(name: "History", colorHex: "#F59E0B", difficulty: .easy, weeklyHours: 3)
    ]
}

private struct ChatRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let responseFormat: ResponseFormat

    enum CodingKeys: String, CodingKey {
        case model, messages
        case responseFormat = "response_format"
    }
}

private struct ChatMessage: Codable {
    let role: String
    let content: String
}

private struct ResponseFormat: Codable { let type: String }
private struct ChatResponse: Codable { let choices: [ChatChoice] }
private struct ChatChoice: Codable { let message: ChatMessage }

private struct GeneratedPlan: Codable { let days: [GeneratedDay] }
private struct GeneratedDay: Codable { let date: String; let tasks: [GeneratedTask] }
private struct GeneratedTask: Codable {
    let subject: String
    let subjectID: String?
    let title: String
    let details: String
    let durationMinutes: Int

    enum CodingKeys: String, CodingKey {
        case subject
        case subjectID = "subject_id"
        case title
        case details
        case durationMinutes = "duration_minutes"
    }
}

private struct StudyPlanRow: Codable {
    let userID: UUID
    let subjectID: UUID
    let title: String
    let objective: String
    let startsAt: Date
    let endsAt: Date

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case subjectID = "subject_id"
        case title, objective
        case startsAt = "starts_at"
        case endsAt = "ends_at"
    }
}
private struct PersistedPlanRow: Codable { let id: UUID }

private struct StudyTaskRow: Codable {
    let userID: UUID
    let planID: UUID
    let title: String
    let notes: String
    let dueAt: Date
    let isCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case planID = "plan_id"
        case title, notes
        case dueAt = "due_at"
        case isCompleted = "is_completed"
    }
}
private struct PersistedTaskRow: Codable { let id: UUID }

private struct ProgressLogRow: Codable {
    let userID: UUID
    let taskID: UUID?
    let planID: UUID?
    let minutesStudied: Int
    let confidence: Int?
    let notes: String?
    let loggedAt: Date?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case taskID = "task_id"
        case planID = "plan_id"
        case minutesStudied = "minutes_studied"
        case confidence, notes
        case loggedAt = "logged_at"
    }
}
private struct PersistedProgressLogRow: Codable { let id: UUID }

enum APIServiceError: LocalizedError {
    case missingOpenAIKey
    case missingSupabaseConfig
    case invalidPlanJSON
    case emptyResponse
    case apiFailure(String)

    var errorDescription: String? {
        switch self {
        case .missingOpenAIKey: return "OPENAI_API_KEY is not configured."
        case .missingSupabaseConfig: return "Supabase configuration is missing."
        case .invalidPlanJSON: return "The generated study plan was malformed."
        case .emptyResponse: return "API returned an empty response."
        case let .apiFailure(message): return "API request failed: \(message)"
        }
    }
}

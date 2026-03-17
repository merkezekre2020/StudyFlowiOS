import Foundation

@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var currentUser: User?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    func signIn(email: String, password: String) async throws {
        _ = password
        try await Task.sleep(for: .milliseconds(300))
        currentUser = User(name: "StudyFlow Student", email: email)
    }

    func register(name: String, email: String, password: String, studyStyle: StudyStyle) async throws {
        _ = password
        try await Task.sleep(for: .milliseconds(350))
        currentUser = User(name: name, email: email, studyStyle: studyStyle)
    }

    func signOut() {
        currentUser = nil
    }

    func loadPreviewSession() {
        currentUser = User(name: "Preview User", email: "preview@studyflow.ai", studyStyle: .visual)
    }
}

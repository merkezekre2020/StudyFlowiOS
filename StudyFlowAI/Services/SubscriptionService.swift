import Foundation

@MainActor
final class SubscriptionService: ObservableObject {
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var planName: String = "Free"

    func refreshSubscription(for user: User?) async {
        guard let user else {
            isPremium = false
            planName = "Free"
            return
        }

        try? await Task.sleep(for: .milliseconds(200))
        let hasPremium = user.email.contains("pro") || user.email.contains("premium")
        isPremium = hasPremium
        planName = hasPremium ? "Pro" : "Free"
    }

    func loadPreviewSubscription() {
        isPremium = true
        planName = "Pro"
    }
}

import SwiftUI

@main
struct StudyFlowAIApp: App {
    @StateObject private var authService: AuthService
    @StateObject private var subscriptionService: SubscriptionService
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var plannerViewModel: StudyPlannerViewModel
    @State private var showRegister = false

    init() {
        let authService = AuthService()
        let subscriptionService = SubscriptionService()
        _authService = StateObject(wrappedValue: authService)
        _subscriptionService = StateObject(wrappedValue: subscriptionService)
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService, subscriptionService: subscriptionService))
        _plannerViewModel = StateObject(wrappedValue: StudyPlannerViewModel())
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    DashboardView()
                        .task {
                            await plannerViewModel.bootstrap(for: authViewModel.currentUser)
                        }
                } else if showRegister {
                    RegisterView(showRegister: $showRegister)
                } else {
                    LoginView(showRegister: $showRegister)
                }
            }
            .environmentObject(authService)
            .environmentObject(subscriptionService)
            .environmentObject(authViewModel)
            .environmentObject(plannerViewModel)
        }
    }
}

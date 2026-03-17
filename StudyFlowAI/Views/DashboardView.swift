import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var subscriptionService: SubscriptionService

    var body: some View {
        NavigationStack {
            List {
                Section("Welcome") {
                    Text(authViewModel.currentUser?.name ?? "Student")
                    Text("Plan: \(subscriptionService.planName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Study") {
                    NavigationLink("Subjects") {
                        SubjectsView()
                    }
                    NavigationLink("Study Plan") {
                        StudyPlanView()
                    }
                }

                Section {
                    Button("Sign Out", role: .destructive) {
                        authViewModel.signOut()
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel.previewAuthenticated)
        .environmentObject(SubscriptionService())
}

import SwiftUI

struct StudyPlanView: View {
    @EnvironmentObject private var plannerViewModel: StudyPlannerViewModel

    var body: some View {
        List {
            if plannerViewModel.isLoading {
                ProgressView("Loading plan...")
            }

            ForEach(plannerViewModel.studyDays) { day in
                NavigationLink {
                    StudyDayView(day: day)
                } label: {
                    VStack(alignment: .leading) {
                        Text(day.date, style: .date)
                            .font(.headline)
                        Text("\(day.tasks.count) tasks • \(day.totalMinutes) minutes")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Study Plan")
    }
}

#Preview {
    NavigationStack {
        StudyPlanView()
            .environmentObject(StudyPlannerViewModel.preview)
    }
}

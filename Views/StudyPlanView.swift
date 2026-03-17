import SwiftUI

struct StudyPlanView: View {
    @EnvironmentObject private var plannerViewModel: StudyPlannerViewModel

    private var weekSections: [(String, [StudyDay])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: plannerViewModel.studyDays) { day in
            let week = calendar.component(.weekOfYear, from: day.date)
            let year = calendar.component(.yearForWeekOfYear, from: day.date)
            return "Week \(week), \(year)"
        }
        return grouped.keys.sorted().map { key in
            let sortedDays = (grouped[key] ?? []).sorted { $0.date < $1.date }
            return (key, sortedDays)
        }
    }

    var body: some View {
        List {
            Section("Analytics") {
                Text("Completed sessions: \(plannerViewModel.analytics.completedSessions)")
                Text("Weekly hours: \(plannerViewModel.analytics.weeklyHours, specifier: "%.1f")")
            }

            if plannerViewModel.isLoading {
                ProgressView("Generating plan...")
            }

            ForEach(weekSections, id: \.0) { week, days in
                Section(week) {
                    ForEach(days) { day in
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
            }
        }
        .navigationTitle("Study Plan")
        .toolbar {
            Button("Generate") {
                Task { await plannerViewModel.generatePlan() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StudyPlanView()
            .environmentObject(StudyPlannerViewModel.preview)
    }
}

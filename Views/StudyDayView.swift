import SwiftUI

struct StudyDayView: View {
    @EnvironmentObject private var plannerViewModel: StudyPlannerViewModel
    let day: StudyDay

    var body: some View {
        List {
            ForEach(day.tasks) { task in
                TaskRowView(task: task) {
                    plannerViewModel.toggleTask(dayID: day.id, taskID: task.id)
                }
            }
        }
        .navigationTitle(day.date.formatted(date: .abbreviated, time: .omitted))
    }
}

#Preview {
    NavigationStack {
        StudyDayView(day: StudyPlannerViewModel.preview.studyDays[0])
            .environmentObject(StudyPlannerViewModel.preview)
    }
}

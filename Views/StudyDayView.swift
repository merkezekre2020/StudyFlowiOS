import SwiftUI

struct StudyDayView: View {
    @EnvironmentObject private var plannerViewModel: StudyPlannerViewModel
    let day: StudyDay

    var body: some View {
        List {
            ForEach(day.tasks) { task in
                TaskRowView(
                    task: task,
                    subjectName: plannerViewModel.subjectName(for: task.subjectID),
                    subjectColorHex: plannerViewModel.color(for: task.subjectID)
                ) {
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

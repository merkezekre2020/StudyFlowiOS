import SwiftUI

struct TaskRowView: View {
    let task: StudyTask
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                Text(task.details)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(task.durationMinutes)m")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TaskRowView(
        task: StudyTask(subjectID: UUID(), title: "Practice Quiz", details: "Complete 20 questions", durationMinutes: 30),
        onToggle: {}
    )
    .padding()
}

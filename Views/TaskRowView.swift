import SwiftUI

struct TaskRowView: View {
    let task: StudyTask
    let subjectName: String
    let subjectColorHex: String
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(subjectName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: subjectColorHex).opacity(0.2))
                        .foregroundStyle(Color(hex: subjectColorHex))
                        .clipShape(Capsule())

                    Spacer()

                    Text("\(task.durationMinutes) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(task.title)
                    .strikethrough(task.isCompleted)
                Text(task.details)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TaskRowView(
        task: StudyTask(subjectID: UUID(), title: "Practice Quiz", details: "Complete 20 questions", durationMinutes: 30),
        subjectName: "Biology",
        subjectColorHex: "#10B981",
        onToggle: {}
    )
    .padding()
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (79, 70, 229)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

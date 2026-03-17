import SwiftUI

struct SubjectsView: View {
    @EnvironmentObject private var plannerViewModel: StudyPlannerViewModel
    @State private var subjectName = ""
    @State private var difficulty: Difficulty = .medium

    var body: some View {
        List {
            Section("Add Subject") {
                TextField("Subject name", text: $subjectName)
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(Difficulty.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }

                Button("Add") {
                    plannerViewModel.addSubject(name: subjectName, difficulty: difficulty)
                    subjectName = ""
                    difficulty = .medium
                }
            }

            Section("Your Subjects") {
                ForEach(plannerViewModel.subjects) { subject in
                    VStack(alignment: .leading) {
                        Text(subject.name)
                        Text("\(subject.weeklyHours) hrs/week • \(subject.difficulty.displayName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Subjects")
    }
}

#Preview {
    NavigationStack {
        SubjectsView()
            .environmentObject(StudyPlannerViewModel.preview)
    }
}

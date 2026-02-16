import SwiftUI

struct PhaseProgressToolbar: ToolbarContent {
    @Environment(AppState.self) private var appState

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack(spacing: 0) {
                ForEach(AppState.WorkflowPhase.allCases, id: \.self) { phase in
                    PhaseStepView(
                        phase: phase,
                        isCurrent: appState.currentPhase == phase,
                        isCompleted: phase.rawValue < appState.currentPhase.rawValue,
                        isAccessible: appState.canAdvance(to: phase)
                    )
                    .onTapGesture {
                        if appState.canAdvance(to: phase) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                appState.currentPhase = phase
                            }
                        }
                    }

                    if phase != .generate {
                        Rectangle()
                            .fill(phase.rawValue < appState.currentPhase.rawValue
                                  ? Color.accentColor : Color.secondary.opacity(0.2))
                            .frame(width: 40, height: 2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct PhaseStepView: View {
    let phase: AppState.WorkflowPhase
    let isCurrent: Bool
    let isCompleted: Bool
    let isAccessible: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(fillColor)
                    .frame(width: 28, height: 28)
                    .overlay {
                        Circle()
                            .strokeBorder(strokeColor, lineWidth: 1.5)
                    }

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: phase.sfSymbol)
                        .font(.caption2)
                        .foregroundStyle(isCurrent ? .primary : .secondary)
                }
            }

            Text(phase.label)
                .font(.caption2)
                .foregroundStyle(isCurrent ? .primary : .secondary)
        }
        .opacity(isAccessible || isCurrent || isCompleted ? 1 : 0.5)
    }

    private var fillColor: Color {
        if isCompleted { return .accentColor }
        if isCurrent { return .accentColor.opacity(0.15) }
        return .clear
    }

    private var strokeColor: Color {
        if isCompleted || isCurrent { return .accentColor }
        return .secondary.opacity(0.3)
    }
}

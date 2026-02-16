import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else if appState.needsOnboarding {
                WelcomeView()
                    .transition(.opacity)
            } else {
                mainWorkspaceView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onAppear {
            // Dismiss splash after ~4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                showSplash = false
            }
        }
    }

    private var mainWorkspaceView: some View {
        NavigationSplitView {
            ProjectSidebar()
        } detail: {
            ZStack {
                switch appState.currentPhase {
                case .import:
                    ImportPhaseView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                case .configure:
                    ConfigurePhaseView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                case .generate:
                    GeneratePhaseView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.currentPhase)
        }
        .toolbar {
            PhaseProgressToolbar()

            ToolbarItemGroup(placement: .primaryAction) {
                if appState.currentPhase != .import {
                    Button {
                        withAnimation { appState.goBack() }
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }

                if appState.currentPhase != .generate {
                    Button {
                        withAnimation { appState.advanceToNext() }
                    } label: {
                        Label("Next", systemImage: "chevron.right")
                    }
                    .disabled(!appState.canAdvance(
                        to: AppState.WorkflowPhase(rawValue: appState.currentPhase.rawValue + 1) ?? .generate
                    ))
                }
            }
        }
    }
}

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("API Key", systemImage: "key") {
                APIKeySettingsView()
            }

            Tab("Output", systemImage: "folder") {
                OutputSettingsView()
            }
        }
        .frame(width: 500, height: 300)
    }
}

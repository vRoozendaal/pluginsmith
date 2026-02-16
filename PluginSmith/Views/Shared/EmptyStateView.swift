import SwiftUI

struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionLabel: String?

    init(
        symbol: String,
        title: String,
        message: String,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actionLabel = actionLabel
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionLabel, let action {
                Button(actionLabel, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: 300)
        .padding(40)
    }
}

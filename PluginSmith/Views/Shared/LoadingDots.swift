import SwiftUI

struct LoadingDots: View {
    @State private var activeDot = 0
    let count: Int
    let color: Color

    init(count: Int = 3, color: Color = .accentColor) {
        self.count = count
        self.color = color
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .opacity(activeDot == index ? 1 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    activeDot = (activeDot + 1) % count
                }
            }
        }
    }
}

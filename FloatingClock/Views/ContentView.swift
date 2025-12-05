import SwiftUI
import Combine

@available(iOS 17.0, *)
struct ContentView: View {
    @State private var currentTime = Date()
    @State private var selectedTheme = ColorTheme.ocean
    // 移除 showThemeSelector
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.ignoresSafeArea()
                
                // 时钟容器
                clockView(screenHeight: geometry.size.height, screenWidth: geometry.size.width)
                
                // 设置按钮 (使用解耦后的组件)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ConfigButtonView(selectedTheme: $selectedTheme)
                            .padding(20)
                    }
                }
            }
        }
        .persistentSystemOverlays(.hidden)
        .statusBar(hidden: true)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .preferredColorScheme(.dark)
    }
    
    private func clockView(screenHeight: CGFloat, screenWidth: CGFloat) -> some View {
        let timeString = formatTime(currentTime)
        let components = parseTimeComponents(timeString)
        
        return ZStack {
            ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                digitContainer(
                    digit: component,
                    position: index,
                    totalDigits: components.count,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    isColon: component == ":"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func digitContainer(digit: String, position: Int, totalDigits: Int, screenHeight: CGFloat, screenWidth: CGFloat, isColon: Bool) -> some View {
        let colors = selectedTheme.gradientColors
        
        let digitIndex: Int
        if position < 2 {
            digitIndex = position
        } else if position == 2 {
            digitIndex = -1
        } else {
            digitIndex = position - 1
        }
        
        let color = isColon ? selectedTheme.colonColor : colors[digitIndex]
        
        return FloatingDigitView(
            digit: digit,
            color: color,
            overlapColor: selectedTheme.overlapColor,
            position: position,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            isColon: isColon,
            fontWeight: FloatConfig.shared.fontWeight
        )
        .zIndex(isColon ? 999 : Double(totalDigits - position))
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func parseTimeComponents(_ timeString: String) -> [String] {
        return timeString.map { String($0) }
    }
}

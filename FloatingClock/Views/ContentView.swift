import SwiftUI
import Combine

@available(iOS 17.0, *)
struct ContentView: View {
    @State private var currentTime = Date()
    @State private var selectedTheme = ColorTheme.ocean
    @State private var showThemeSelector = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.ignoresSafeArea()
                
                // 时钟容器
                clockView(screenHeight: geometry.size.height, screenWidth: geometry.size.width)
                
                // 主题选择按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        themeButton
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
        
        // 使用ZStack让每个数字独立定位
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
        
        // 计算实际的数字索引（跳过冒号位置）
        // 位置: 0(数字0) 1(数字1) 2(冒号) 3(数字2) 4(数字3)
        // 映射: 0->colors[0], 1->colors[1], 2->冒号色, 3->colors[2], 4->colors[3]
        let digitIndex: Int
        if position < 2 {
            digitIndex = position  // 前两位: 0, 1
        } else if position == 2 {
            digitIndex = -1  // 冒号位置
        } else {
            digitIndex = position - 1  // 后两位: 3->2, 4->3
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
            fontWeight: ClockLayoutConfig.fontWeight
        )
        .zIndex(isColon ? 999 : Double(totalDigits - position))
    }
    
    private var themeButton: some View {
        Button(action: {
            showThemeSelector.toggle()
        }) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        .popover(isPresented: $showThemeSelector) {
            ThemeSelectorView(selectedTheme: $selectedTheme)
                .presentationCompactAdaptation(.popover)
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 格式显示前导0
        return formatter.string(from: date)
    }
    
    private func parseTimeComponents(_ timeString: String) -> [String] {
        return timeString.map { String($0) }
    }
}

// MARK: - Theme Selector View
struct ThemeSelectorView: View {
    @Binding var selectedTheme: ColorTheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("选择配色")
                .font(.headline)
                .padding(.top)
            
            ForEach(ColorTheme.allThemes) { theme in
                Button(action: {
                    selectedTheme = theme
                    dismiss()
                }) {
                    HStack {
                        HStack(spacing: 5) {
                            ForEach(theme.gradientColors.indices, id: \.self) { index in
                                Circle()
                                    .fill(theme.gradientColors[index])
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                        Text(theme.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedTheme.id == theme.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}

//#Preview {
//    ContentView()
//}

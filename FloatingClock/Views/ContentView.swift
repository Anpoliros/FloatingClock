import SwiftUI
import Combine

struct ContentView: View {
    @State private var currentTime = Date()
    @State private var selectedTheme = ColorTheme.default
    @State private var showThemeSelector = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.ignoresSafeArea()
                
                // 时钟容器
                clockView(screenHeight: geometry.size.height, screenWidth: geometry.size.width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 主题选择按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        themeButton
                            .padding(30)
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
        
        // 计算更合理的间距，让时钟显示更"矮胖"
        // 根据屏幕宽度和数字数量动态计算间距
        let digitCount = components.filter { $0 != ":" }.count
        let totalWidth = screenWidth * 0.9 // 使用90%的屏幕宽度
        let digitWidth = screenHeight * 0.4 // 每个数字的宽度
        let totalDigitWidth = CGFloat(components.count) * digitWidth
        
        // 计算负间距，让数字适当重叠
        let spacing = (totalWidth - totalDigitWidth) / CGFloat(components.count - 1)
        
        return HStack(spacing: spacing) {
            ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                digitContainer(
                    digit: component,
                    position: index,
                    totalDigits: components.count,
                    screenHeight: screenHeight,
                    isColon: component == ":"
                )
            }
        }
    }
    
    private func digitContainer(digit: String, position: Int, totalDigits: Int, screenHeight: CGFloat, isColon: Bool) -> some View {
        let colors = selectedTheme.gradientColors
        
        // 根据位置分配颜色（深浅交错）
        // 对于冒号，使用特殊的colonColor
        let colorIndex = position % colors.count
        let color = isColon ? selectedTheme.colonColor : colors[colorIndex]
        
        return FloatingDigitView(
            digit: digit,
            color: color,
            overlapColor: selectedTheme.overlapColor,
            position: position,
            screenHeight: screenHeight
        )
        .frame(width: screenHeight * 0.4) // 给每个字符足够的空间
        .zIndex(isColon ? 999 : Double(totalDigits - position)) // 冒号在最上层
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
        formatter.dateFormat = "H:mm"
        return formatter.string(from: date)
    }
    
    private func parseTimeComponents(_ timeString: String) -> [String] {
        // 将时间字符串分解为单个字符数组
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

#Preview {
    ContentView()
}

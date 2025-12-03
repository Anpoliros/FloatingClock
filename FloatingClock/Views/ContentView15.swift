import SwiftUI

// iOS 15兼容版本
@available(iOS 15.0, *)
struct ContentView15: View {
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
        
        let colorIndex = position % colors.count
        let color = isColon ? selectedTheme.colonColor : colors[colorIndex]
        
        return FloatingDigitView15(
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
            ThemeSelectorView15(selectedTheme: $selectedTheme)
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

// MARK: - Theme Selector View (iOS 15版本)
@available(iOS 15.0, *)
struct ThemeSelectorView15: View {
    @Binding var selectedTheme: ColorTheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("选择配色")
                .font(.headline)
                .padding(.top)
            
            ForEach(ColorTheme.allThemes) { theme in
                Button(action: {
                    selectedTheme = theme
                    presentationMode.wrappedValue.dismiss()
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

@available(iOS 15.0, *)
struct ContentView15_Previews: PreviewProvider {
    static var previews: some View {
        ContentView15()
    }
}

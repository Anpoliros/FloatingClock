import SwiftUI
import Combine

// iOS 15兼容版本
@available(iOS 15.0, *)
struct ContentView15: View {
    @State private var currentTime = Date()
    @State private var selectedTheme = ColorTheme.ocean
    
    // 新增状态
    @State private var showSettings = false
    @State private var showControls = false
    // iOS 15 状态容器需要稍微变通一下，因为 DispatchWorkItem 不易直接存为 State
    // 这里我们用一个简单的 Timer 或者 Just State 即可，或者用引用类型包装
    @State private var timerHolder = TimerHolder()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                clockView(screenHeight: geometry.size.height, screenWidth: geometry.size.width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // 背景点击唤醒
                    .contentShape(Rectangle())
                    .onTapGesture {
                        wakeControls()
                    }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ConfigButtonView(selectedTheme: $selectedTheme, showSettings: $showSettings)
                            .padding(30)
                            // 逻辑：菜单开着 -> 不透明；菜单关着且已唤醒 -> 不透明；否则 -> 透明
                            .opacity(showSettings ? 1.0 : (showControls ? 1.0 : 0.0))
                            .animation(.easeInOut(duration: 0.3), value: showControls)
                            .animation(.easeInOut(duration: 0.3), value: showSettings)
                    }
                }
            }
        }
        .statusBar(hidden: true)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .preferredColorScheme(.dark)
        .onChange(of: showSettings) { newValue in
            if newValue {
                cancelHideTimer()
                showControls = true
            } else {
                scheduleHideTimer()
            }
        }
    }
    
    // MARK: - Logic
    
    private func wakeControls() {
        if showSettings { return }
        withAnimation { showControls = true }
        scheduleHideTimer()
    }
    
    private func scheduleHideTimer() {
        cancelHideTimer()
        // 5秒后隐藏
        let workItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 1.0)) {
                showControls = false
            }
        }
        timerHolder.workItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
    }
    
    private func cancelHideTimer() {
        timerHolder.workItem?.cancel()
        timerHolder.workItem = nil
    }
    
    // Helper Class for State (iOS 15 Safe)
    class TimerHolder {
        var workItem: DispatchWorkItem?
    }
    
    // MARK: - Clock Views (保持不变)
    
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
        
        return FloatingDigitView15(
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func parseTimeComponents(_ timeString: String) -> [String] {
        return timeString.map { String($0) }
    }
}

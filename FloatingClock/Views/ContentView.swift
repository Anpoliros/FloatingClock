import SwiftUI
import Combine

@available(iOS 17.0, *)
struct ContentView: View {
    @State private var currentTime = Date()
    @State private var selectedTheme = ColorTheme.ocean
    
    // 新增状态管理
    @State private var showSettings = false      // 控制菜单是否打开
    @State private var showControls = false      // 控制按钮是否可见 (透明度)
    @State private var hideTimer: DispatchWorkItem? // 用于延时隐藏的任务
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.ignoresSafeArea()
                
                // 时钟容器
                clockView(screenHeight: geometry.size.height, screenWidth: geometry.size.width)
                    // 背景点击区：点击任意空白处唤醒按钮
                    .contentShape(Rectangle())
                    .onTapGesture {
                        wakeControls()
                    }
                
                // 设置按钮
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ConfigButtonView(selectedTheme: $selectedTheme, showSettings: $showSettings)
                            .padding(20)
                            // 如果菜单打开，强制显示(不透明)；否则根据showControls决定
                            .opacity(showSettings ? 1.0 : (showControls ? 1.0 : 0.0))
                            // 添加动画，使透明度变化平滑
                            .animation(.easeInOut(duration: 0.3), value: showControls)
                            .animation(.easeInOut(duration: 0.3), value: showSettings)
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
        // 监听菜单开关状态
        .onChange(of: showSettings) { oldValue, newValue in
            if newValue {
                // 菜单打开时，取消自动隐藏，保持常亮
                cancelHideTimer()
                showControls = true
            } else {
                // 菜单关闭后，启动5秒倒计时
                scheduleHideTimer()
            }
        }
    }
    
    // MARK: - Auto Hide Logic
    
    private func wakeControls() {
        // 如果菜单正在显示，不处理背景点击（或者可以做成点击背景关闭菜单，目前逻辑是不处理）
        if showSettings { return }
        
        // 唤醒按钮
        withAnimation {
            showControls = true
        }
        
        // 重置计时器
        scheduleHideTimer()
    }
    
    private func scheduleHideTimer() {
        // 先取消之前的计时器
        cancelHideTimer()
        
        // 创建新的计时任务
        let task = DispatchWorkItem {
            withAnimation(.easeOut(duration: 1.0)) {
                showControls = false
            }
        }
        hideTimer = task
        
        // 5秒后执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
    }
    
    private func cancelHideTimer() {
        hideTimer?.cancel()
        hideTimer = nil
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func parseTimeComponents(_ timeString: String) -> [String] {
        return timeString.map { String($0) }
    }
}

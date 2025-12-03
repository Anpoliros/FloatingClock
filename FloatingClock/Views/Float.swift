import SwiftUI

struct FloatingDigitView: View {
    let digit: String
    let color: Color
    let overlapColor: Color
    let position: Int
    let screenHeight: CGFloat
    
    @State private var offset: CGSize = .zero
    @State private var isEntering = false
    @State private var currentDigit: String
    
    // 根据屏幕高度计算字体大小（占屏幕高度的80%左右）
    private var fontSize: CGFloat {
        screenHeight * 0.95
    }
    
    // 浮动范围也要根据字体大小调整，确保数字会重合
    private var floatRange: CGFloat {
        fontSize * 0.05
    }
    
    init(digit: String, color: Color, overlapColor: Color, position: Int, screenHeight: CGFloat) {
        self.digit = digit
        self.color = color
        self.overlapColor = overlapColor
        self.position = position
        self.screenHeight = screenHeight
        _currentDigit = State(initialValue: digit)
    }
    
    var body: some View {
        ZStack {
            // 主数字/冒号
            Text(currentDigit)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // 重叠效果 - 使用blend mode
            Text(currentDigit)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(overlapColor)
                .blendMode(.screen)
                .opacity(0.6)
        }
        .fixedSize() // 防止文字被裁剪
        .offset(offset)
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 100)
        .onAppear {
            startFloatingAnimation()
            startEnterAnimation()
        }
        .onChange(of: digit) { oldValue, newValue in
            if oldValue != newValue {
                restartAnimationWithNewDigit(newValue)
            }
        }
    }
    
    private func startEnterAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            isEntering = true
        }
        
        // 模拟浮力 - 向上弹跳一点
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset.height -= 15
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    offset.height += 15
                }
            }
        }
    }
    
    private func startFloatingAnimation() {
        // 为每个数字创建不同的随机种子，避免同步
        let randomDelay = Double.random(in: 0...5)
        let baseSpeed = 20.0 // 显著增加基础速度，让动画更慢
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            performFloatCycle(speed: baseSpeed + Double(position) * 1.5)
        }
    }
    
    private func performFloatCycle(speed: Double) {
        // 生成随机目标位置
        let targetX = CGFloat.random(in: -floatRange...floatRange)
        let targetY = CGFloat.random(in: -floatRange...floatRange)
        
        withAnimation(.easeInOut(duration: speed)) {
            offset = CGSize(width: targetX, height: targetY)
        }
        
        // 递归调用实现持续浮动 - 速度范围 15-25秒
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            performFloatCycle(speed: Double.random(in: 15...25))
        }
    }
    
    private func restartAnimationWithNewDigit(_ newDigit: String) {
        // 1. 先让旧数字退出（向上消失）
        withAnimation(.easeOut(duration: 0.4)) {
            offset.height -= 150
            isEntering = false
        }
        
        // 2. 等旧数字完全消失后，更换为新数字
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentDigit = newDigit
            offset = .zero
            
            // 3. 新数字从下方进入
            startEnterAnimation()
        }
    }
}

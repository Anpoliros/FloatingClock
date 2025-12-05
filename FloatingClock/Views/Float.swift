import SwiftUI

@available(iOS 17.0, *)
struct FloatingDigitView: View {
    let digit: String
    let color: Color
    let overlapColor: Color
    let position: Int
    let screenHeight: CGFloat
    let screenWidth: CGFloat
    let isColon: Bool
    let fontWeight: Font.Weight
    
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var isEntering = false
    @State private var currentDigit: String
    
    // 关键修改：使用 @ObservedObject 监听配置变化
    @ObservedObject private var config = FloatConfig.shared
    
    // 根据屏幕高度计算字体大小
    private var fontSize: CGFloat {
        screenHeight * config.fontSizeRatio
    }
    
    // 浮动动画的范围
    private var floatRangeX: CGFloat {
        screenWidth * config.floatRangeXRatio
    }
    
    private var floatRangeY: CGFloat {
        screenHeight * config.floatRangeYRatio
    }
    
    private var rotationRange: Double {
        config.rotationRange
    }
    
    // 根据位置返回初始旋转角度
    private var baseRotationAngle: Double {
        config.getBaseRotation(position: position, isColon: isColon)
    }
    
    // 根据位置返回透明度
    private var digitOpacity: Double {
        if isColon { return 0.98 }
        return 1.0
    }
    
    // 计算数字在屏幕上的中心位置
    private var centerPosition: CGPoint {
        // 当 config.spreadFactor 变化时，horizontalPositions 会重新计算
        let xRatio = config.horizontalPositions[position]
        let x = screenWidth * xRatio
        let y = screenHeight * 0.5
        return CGPoint(x: x, y: y)
    }
    
    init(digit: String, color: Color, overlapColor: Color, position: Int, screenHeight: CGFloat, screenWidth: CGFloat, isColon: Bool, fontWeight: Font.Weight = .bold) {
        self.digit = digit
        self.color = color
        self.overlapColor = overlapColor
        self.position = position
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.isColon = isColon
        self.fontWeight = fontWeight
        _currentDigit = State(initialValue: digit)
        _rotation = State(initialValue: FloatConfig.shared.getBaseRotation(position: position, isColon: isColon))
    }
    
    var body: some View {
        ZStack {
            // 主数字/冒号
            Text(currentDigit)
                .font(.system(size: fontSize, weight: config.fontWeight, design: config.fontDesign))
                .foregroundStyle(color)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // 重叠光效
            Text(currentDigit)
                .font(.system(size: fontSize, weight: config.fontWeight, design: config.fontDesign))
                .foregroundStyle(overlapColor)
                .blendMode(.plusLighter)
                .opacity(0.4)
        }
        .opacity(digitOpacity)
        .rotationEffect(.degrees(rotation))
        .fixedSize()
        // position 修改时会实时刷新布局
        .position(x: centerPosition.x + offsetX, y: centerPosition.y + offsetY)
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 100)
        .onAppear {
            startEnterAnimation()
            startFloatingAnimation()
        }
        #if swift(>=5.9)
        .onChange(of: digit) { oldValue, newValue in
            if oldValue != newValue {
                restartAnimationWithNewDigit(newValue)
            }
        }
        #else
        .onReceive(Just(digit)) { newDigit in
            if currentDigit != newDigit {
                restartAnimationWithNewDigit(newDigit)
            }
        }
        #endif
    }
    
    // 动画逻辑保持不变...
    private func startEnterAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            isEntering = true
        }
    }
    
    private func startFloatingAnimation() {
        let randomDelay = Double.random(in: 0...5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            performFloatCycle(speed: config.baseSpeed + Double(position) * 1.5)
        }
    }
    
    private func performFloatCycle(speed: Double) {
        let targetX = CGFloat.random(in: -floatRangeX...floatRangeX)
        let targetY = CGFloat.random(in: -floatRangeY...floatRangeY)
        let targetRotation = baseRotationAngle + Double.random(in: -rotationRange...rotationRange)
        
        withAnimation(.easeInOut(duration: speed)) {
            offsetX = targetX
            offsetY = targetY
            rotation = targetRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            performFloatCycle(speed: Double.random(in: 15...25))
        }
    }
    
    private func restartAnimationWithNewDigit(_ newDigit: String) {
        withAnimation(.easeOut(duration: 0.4)) {
            offsetY -= 150
            isEntering = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentDigit = newDigit
            offsetX = 0
            offsetY = 0
            rotation = baseRotationAngle
            startEnterAnimation()
        }
    }
}

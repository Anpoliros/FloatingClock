import SwiftUI
import Combine

@available(iOS 15.0, *)
struct FloatingDigitView15: View {
    // ... 属性保持不变
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
    @State private var digitId: UUID = UUID()
    
    // 关键修改：监听配置
    @ObservedObject private var config = FloatConfig.shared
    
    private var fontSize: CGFloat {
        screenHeight * config.fontSizeRatio
    }
    
    private var floatRangeX: CGFloat { screenWidth * 0.01 }
    private var floatRangeY: CGFloat { screenHeight * config.floatRangeYRatio }
    private var rotationRange: Double { config.rotationRange }
    
    private var baseRotationAngle: Double {
        config.getBaseRotation(position: position, isColon: isColon)
    }
    
    private var digitOpacity: Double {
        if isColon { return 0.98 }
        switch position {
        case 0, 3: return 0.75
        case 1, 4: return 0.85
        default: return 0.8
        }
    }
    
    private var centerPosition: CGPoint {
        // 监听 spreadFactor
        let x = screenWidth * config.horizontalPositions[position]
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
            Text(currentDigit)
                .font(.system(size: fontSize, weight: config.fontWeight, design: config.fontDesign))
                .foregroundStyle(color)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            Text(currentDigit)
                .font(.system(size: fontSize, weight: config.fontWeight, design: config.fontDesign))
                .foregroundStyle(overlapColor)
                .blendMode(.plusLighter)
                .opacity(0.4)
        }
        .opacity(digitOpacity)
        .rotationEffect(.degrees(rotation))
        .fixedSize()
        .position(x: centerPosition.x + offsetX, y: centerPosition.y + offsetY)
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 100)
        .id(digitId)
        .onAppear {
            startFloatingAnimation()
            startEnterAnimation()
        }
        .id("\(digit)-\(position)")
        .task(id: digit) {
            if currentDigit != digit {
                restartAnimationWithNewDigit(digit)
            }
        }
    }
    
    // 动画函数保持不变 (startEnterAnimation, startFloatingAnimation, performFloatCycle, restartAnimationWithNewDigit)
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
            digitId = UUID()
            offsetX = 0
            offsetY = 0
            rotation = baseRotationAngle
            startEnterAnimation()
        }
    }
}

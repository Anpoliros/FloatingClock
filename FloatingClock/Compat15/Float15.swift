import SwiftUI
import Combine

@available(iOS 15.0, *)
struct FloatingDigitView15: View {
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
    
    @ObservedObject private var config = FloatConfig.shared
    
    private var fontSize: CGFloat { screenHeight * config.fontSizeRatio }
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
    
    private var activeOpacity: Double {
        if config.animationStyle == .crossfade {
            return isEntering ? digitOpacity : 0.0
        } else {
            return digitOpacity
        }
    }

    private var centerPosition: CGPoint {
        let x = screenWidth * config.horizontalPositions[position]
        let visualCorrection = isColon ? -(screenHeight * 0.08) : 0
        let y = (screenHeight * 0.5) + visualCorrection
        
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
        .opacity(activeOpacity)
        .rotationEffect(.degrees(rotation))
        .fixedSize()
        .position(x: centerPosition.x + offsetX, y: centerPosition.y + offsetY)
        // 初始加载位置逻辑
        .offset(y: isEntering ? 0 : (config.animationStyle == .crossfade ? 100 : screenHeight))
        .id(digitId)
        .onAppear {
            isEntering = true
            startFloatingAnimation()
        }
        .task(id: digit) {
            if currentDigit != digit {
                restartAnimationWithNewDigit(digit)
            }
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
        let exitDuration = 0.5
        let resetDelay: Double
        
        // 1. 退出
        if config.animationStyle == .fly {
            withAnimation(.easeIn(duration: exitDuration)) {
                offsetY = -screenHeight // 飞向上方
            }
            resetDelay = exitDuration
        } else {
            withAnimation(.easeOut(duration: exitDuration * 0.8)) {
                offsetY = -screenHeight
                isEntering = false
            }
            resetDelay = exitDuration * 0.8
        }
        
        // 2. 进入
        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
            currentDigit = newDigit
            digitId = UUID()
            rotation = baseRotationAngle
            
            if config.animationStyle == .fly {
                // Fly: 瞬移到下方
                offsetY = screenHeight
                offsetX = 0
                // 向上飞回
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    offsetY = 0
                }
            } else {
                // Crossfade 模式
                offsetX = 0
                offsetY = 0
                rotation = baseRotationAngle
//                withAnimation(.easeIn(duration: exitDuration * 0.8)) {
//                    isEntering = true
//                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    isEntering = true
                }
            }
        }
    }
}

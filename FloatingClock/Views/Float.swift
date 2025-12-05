import SwiftUI
import Combine

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
    
    @ObservedObject private var config = FloatConfig.shared
    
    private var fontSize: CGFloat { screenHeight * config.fontSizeRatio }
    private var floatRangeX: CGFloat { screenWidth * config.floatRangeXRatio }
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
    
    // 计算当前是否需要隐藏 (用于Crossfade)
    private var activeOpacity: Double {
        if config.animationStyle == .crossfade {
            // Crossfade: 进入前完全透明
            return isEntering ? digitOpacity : 0.0
        } else {
            // Fly: 始终保持不透明度 (依靠 Y 轴位移隐藏)
            return digitOpacity
        }
    }
    
//    private var centerPosition: CGPoint {
//        let x = screenWidth * config.horizontalPositions[position]
//        let y = screenHeight * 0.5
//        return CGPoint(x: x, y: y)
//    }
//    
//    // 在 FloatingDigitView (及 FloatingDigitView15) 中找到 centerPosition

    private var centerPosition: CGPoint {
        // 监听 spreadFactor
        let x = screenWidth * config.horizontalPositions[position]
        
        // 原有逻辑: let y = screenHeight * 0.5
        
        // 修改后: 针对冒号进行视觉修正
        // 冒号通常偏下，需要向上提。screenHeight * 0.1 左右通常能视觉居中，可根据感觉微调
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
        // MARK: - Opacity Logic Modified
        .opacity(activeOpacity)
        .rotationEffect(.degrees(rotation))
        .fixedSize()
        .position(x: centerPosition.x + offsetX, y: centerPosition.y + offsetY)
        // MARK: - Initial Entry Logic
        // 初始加载时，如果是 Crossfade 则透明度0；如果是 Fly 则在屏幕下方
        .offset(y: isEntering ? 0 : (config.animationStyle == .crossfade ? 100 : screenHeight))
        .onAppear {
            isEntering = true // 触发初始进场
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
        
        // 1. 旧数字退出
        if config.animationStyle == .fly {
            // Fly: 向上飞出屏幕顶部 (保持不透明)
            withAnimation(.easeIn(duration: exitDuration)) {
                offsetY = -screenHeight // 飞向顶部
            }
            resetDelay = exitDuration
        } else {
            // Crossfade: 原地淡出
            withAnimation(.easeOut(duration: exitDuration * 0.8)) {
                offsetY = -screenHeight
                isEntering = false
            }
            resetDelay = exitDuration * 0.8
        }
        
        // 2. 重置并进入新数字
        DispatchQueue.main.asyncAfter(deadline: .now() + resetDelay) {
            currentDigit = newDigit
            rotation = baseRotationAngle
            
            if config.animationStyle == .fly {
                // Fly 模式: 瞬移到屏幕正下方，准备向上飞入
                offsetY = screenHeight
                offsetX = 0
                // 立即执行进入动画
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                    offsetY = 0 // 飞回中心
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

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
    
    // 配置：数字和冒号在屏幕上的水平位置（相对于屏幕宽度的百分比）
    private static let horizontalPositions: [CGFloat] = [0.15, 0.37, 0.5, 0.63, 0.85]
    
    // 根据屏幕高度计算字体大小
    private var fontSize: CGFloat {
        screenHeight * 0.95
    }
    
    // 浮动动画的范围
    private var floatRangeX: CGFloat {
        screenWidth * 0.02  // 水平浮动范围
    }
    
    private var floatRangeY: CGFloat {
        screenHeight * 0.00  // 垂直浮动范围
    }
    
    private var rotationRange: Double {
        5.0  // 旋转范围 ±15度
    }
    
    // 根据位置返回初始旋转角度
    private var baseRotationAngle: Double {
        if isColon { return 0 }
        
        switch position {
        case 0: return -5
        case 1: return -3
        case 3: return 3
        case 4: return 5
        default: return 0
        }
    }
    
    // 根据位置返回透明度
    private var digitOpacity: Double {
        if isColon { return 0.98 }
        
        switch position {
        case 0, 3: return 0.75
        case 1, 4: return 0.85
        default: return 0.8
        }
    }
    
    // 计算数字在屏幕上的中心位置
    private var centerPosition: CGPoint {
        let x = screenWidth * Self.horizontalPositions[position]
        let y = screenHeight * 0.5  // 垂直居中
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
        _rotation = State(initialValue: Self.getBaseRotation(position: position, isColon: isColon))
    }
    
    private static func getBaseRotation(position: Int, isColon: Bool) -> Double {
        if isColon { return 0 }
        switch position {
        case 0: return -7
        case 1: return -5
        case 3: return 5
        case 4: return 7
        default: return 0
        }
    }
    
    var body: some View {
        ZStack {
            // 主数字/冒号
            Text(currentDigit)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                .foregroundStyle(color)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // 重叠光效
            Text(currentDigit)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
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
        .onAppear {
            startEnterAnimation()
            startFloatingAnimation()
        }
        // 条件编译：根据iOS版本选择不同的API
        #if swift(>=5.9) // Swift 5.9+ (iOS 17+)
        .onChange(of: digit) { oldValue, newValue in
            if oldValue != newValue {
                restartAnimationWithNewDigit(newValue)
            }
        }
        #else // iOS 15-16
        .onReceive(Just(digit)) { newDigit in
            if currentDigit != newDigit {
                restartAnimationWithNewDigit(newDigit)
            }
        }
        #endif
    }
    
    private func startEnterAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            isEntering = true
        }
        
//        // 模拟浮力弹跳
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
//            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
//                offsetY -= 15
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
//                    offsetY += 15
//                }
//            }
//        }
    }
    
    private func startFloatingAnimation() {
        let randomDelay = Double.random(in: 0...5)
        let baseSpeed = 20.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            performFloatCycle(speed: baseSpeed + Double(position) * 1.5)
        }
    }
    
    private func performFloatCycle(speed: Double) {
        // 生成随机目标位置（包含水平、垂直和旋转）
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
        // 旧数字向上消失
        withAnimation(.easeOut(duration: 0.4)) {
            offsetY -= 150
            isEntering = false
        }
        
        // 更换新数字并重新进入
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentDigit = newDigit
            offsetX = 0
            offsetY = 0
            rotation = baseRotationAngle
            startEnterAnimation()
        }
    }
}

// MARK: - 配置结构
struct ClockLayoutConfig {
    // 数字和冒号的水平位置（相对屏幕宽度的百分比）
    static var horizontalPositions: [CGFloat] = [0.22, 0.37, 0.5, 0.63, 0.78]
    
    // 字体粗细
    static var fontWeight: Font.Weight = .heavy
    
    // 可以根据需要调整这些值
    // 例如：
    // - 让数字更紧凑：[0.25, 0.38, 0.5, 0.62, 0.75]
    // - 让数字更分散：[0.18, 0.35, 0.5, 0.65, 0.82]
}


#if !swift(>=5.9)
// MARK: - Just Publisher for iOS 15-16
struct Just<Output>: Publisher {
    typealias Failure = Never
    
    let output: Output
    
    init(_ output: Output) {
        self.output = output
    }
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = JustSubscription(output: output, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
    private class JustSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        let output: Output
        var subscriber: S?
        
        init(output: Output, subscriber: S) {
            self.output = output
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            if let subscriber = subscriber {
                _ = subscriber.receive(output)
                subscriber.receive(completion: .finished)
                self.subscriber = nil
            }
        }
        
        func cancel() {
            subscriber = nil
        }
    }
}
#endif

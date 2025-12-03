import SwiftUI
import Combine

// iOS 15兼容版本
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
    
    // 配置：数字和冒号在屏幕上的水平位置
    private static let horizontalPositions: [CGFloat] = [0.22, 0.37, 0.5, 0.63, 0.78]
    
    private var fontSize: CGFloat {
        screenHeight * 0.65
    }
    
    private var floatRangeX: CGFloat {
        screenWidth * 0.08
    }
    
    private var floatRangeY: CGFloat {
        screenHeight * 0.08
    }
    
    private var rotationRange: Double {
        15.0
    }
    
    private var baseRotationAngle: Double {
        if isColon { return 0 }
        
        switch position {
        case 0: return -7
        case 1: return -5
        case 3: return 5
        case 4: return 7
        default: return 0
        }
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
        let x = screenWidth * Self.horizontalPositions[position]
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
            Text(currentDigit)
                .font(.system(size: fontSize, weight: fontWeight, design: .rounded))
                .foregroundStyle(color)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
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
        .id(digitId)
        .onAppear {
            startFloatingAnimation()
            startEnterAnimation()
        }
        .onReceive(Just(digit)) { newDigit in
            if currentDigit != newDigit {
                restartAnimationWithNewDigit(newDigit)
            }
        }
    }
    
    private func startEnterAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            isEntering = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offsetY -= 15
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    offsetY += 15
                }
            }
        }
    }
    
    private func startFloatingAnimation() {
        let randomDelay = Double.random(in: 0...5)
        let baseSpeed = 20.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            performFloatCycle(speed: baseSpeed + Double(position) * 1.5)
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

// MARK: - Just Publisher
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

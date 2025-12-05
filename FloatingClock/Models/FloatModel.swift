//
//  FloatModel.swift
//  FloatingClock
//
//  Created by anpoliros on 2025/12/5.
//

import SwiftUI
import Combine

// MARK: - Animation Style Enum
enum DigitAnimationStyle: String, CaseIterable, Identifiable {
    case fly = "飞入/飞出 (Fly In/Out)"
    case crossfade = "淡入/淡出 (Crossfade)"
    
    var id: String { self.rawValue }
}

// MARK: - Float & Layout Configuration
class FloatConfig: ObservableObject {
    // 单例模式，方便全局访问
    static let shared = FloatConfig()
    
    // 私有初始化，强制使用单例
    private init() {}
    
    // MARK: - 新增：动画样式配置
    /// 数字变化时的动画风格
    @Published var animationStyle: DigitAnimationStyle = .fly // 默认使用飞入/飞出
    
    // MARK: - 字体配置
    /// 字体粗细
    @Published var fontWeight: Font.Weight = .heavy
    /// 字体设计
    @Published var fontDesign: Font.Design = .rounded
    /// 字体大小占屏幕高度的比例 (0.0 - 1.0)
    @Published var fontSizeRatio: CGFloat = 0.95
    
    // MARK: - 分布配置
    /// 扩散系数：1.0 为默认间距，大于 1.0 更分散，小于 1.0 更紧凑
    @Published var spreadFactor: CGFloat = 1.0
    
    /// 基于屏幕中心的原始偏移量 (对应 0,1,2,3,4 五个位置)
    /// 原始位置: [0.15, 0.37, 0.5, 0.63, 0.85] -> 减去 0.5 得到偏移
    private let baseOffsets: [CGFloat] = [-0.35, -0.13, 0.0, 0.13, 0.35]
    
    /// 获取计算后的水平位置数组
    var horizontalPositions: [CGFloat] {
        return baseOffsets.map { offset in
            0.5 + (offset * spreadFactor)
        }
    }
    
    // MARK: - 动画配置
    /// 水平浮动范围 (屏幕宽度的比例)
    var floatRangeXRatio: CGFloat = 0.02
    /// 垂直浮动范围 (屏幕高度的比例)
    var floatRangeYRatio: CGFloat = 0.00
    /// 旋转动画的随机范围 (角度)
    var rotationRange: Double = 5.0
    
    /// 基础浮动速度 (秒)
    var baseSpeed: Double = 20.0
    
    // MARK: - 初始角度配置
    /// 长度为5的随机初始角度数组，满足：
    /// - 第0、1、3、4位：两正两负（位置随机），绝对值在1-4之间
    /// - 第2位：补齐使总和为0，绝对值在1-4之间
    lazy var startAngel: [Double] = {
        return generateValidAngles()
    }()
    
    /// 生成满足条件的角度数组
    private func generateValidAngles() -> [Double] {
        // 创建长度为5的数组，初始化为0
        var angles = Array(repeating: 0.0, count: 5)
        
        // 生成两个正数和两个负数
        let positiveAngles = [
            Double.random(in: 1.0...4.0),
            Double.random(in: 1.0...4.0)
        ]
        let negativeAngles = [
            -Double.random(in: 1.0...4.0),
            -Double.random(in: 1.0...4.0)
        ]
        
        // 合并正负数组并打乱顺序
        var fourAngles = positiveAngles + negativeAngles
        fourAngles.shuffle()
        
        // 将这4个角度分配到位置 0、1、3、4
        let positions = [0, 1, 3, 4]
        for (index, position) in positions.enumerated() {
            angles[position] = fourAngles[index]
        }
        
        // 计算前4个角度的和
        let sum = angles[0] + angles[1] + angles[3] + angles[4]
        
        // 第2位 = -sum，确保总和为0
        let middleAngle = -sum
        
        // 检查第2位是否满足条件（绝对值在1-4之间）
        if abs(middleAngle) >= 1.0 && abs(middleAngle) <= 4.0 {
            angles[2] = middleAngle
            return angles
        } else {
            // 不满足条件，递归重新生成
            return generateValidAngles()
        }
    }
    
    func getBaseRotation(position: Int, isColon: Bool) -> Double {
        if isColon { return startAngel[2] }
        guard position >= 0 && position < startAngel.count else { return 0 }
        return startAngel[position]
    }
}

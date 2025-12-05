//
//  FloatModel.swift
//  FloatingClock
//
//  Created by anpoliros on 2025/12/5.
//

import SwiftUI
import Combine

// MARK: - Float & Layout Configuration
class FloatConfig: ObservableObject {
    // 单例模式，方便全局访问
    static let shared = FloatConfig()
    
    // 私有初始化，强制使用单例
    private init() {}
    
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
    func getBaseRotation(position: Int, isColon: Bool) -> Double {
        if isColon { return 0 }
        switch position {
        case 0: return -7
        case 1: return -5
        case 3: return 5
        case 4: return 7
        default: return 0
        }
    }
}

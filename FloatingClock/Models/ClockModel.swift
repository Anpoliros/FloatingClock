import SwiftUI

// MARK: - Color Theme Model

struct ColorTheme: Identifiable, Equatable {
    let id = UUID()
    let name: String
    
    // 直接指定4个渐变色（深浅交错）
    let gradientColors: [Color]
    
    // 冒号颜色 - 明亮色
    var colonColor: Color {
        return Color("Colon").opacity(0.6)
    }
    
    // 重叠部分颜色 - 不同的明亮色
    var overlapColor: Color {
        return Color.white.opacity(0.7)
    }
    
    // 初始化方法：直接传入4个颜色
    init(name: String, colors: [Color]) {
        self.name = name
        self.gradientColors = colors
    }
    
    // 海洋主题
    static let ocean = ColorTheme(
        name: "海洋",
        colors: [
            Color("Ocean/1").opacity(1.0),          // 深蓝
            Color("Ocean/2").opacity(0.75),                    // 浅蓝
            Color("Ocean/1").opacity(1.0),      // 中深蓝
            Color("Ocean/2").opacity(0.75)        // 中浅蓝
        ]
    )
    
    // 草甸主题
    static let grass = ColorTheme(
        name: "草甸",
        colors: [
            Color("Grass/1"),                    // 深绿
            Color("Grass/2"),                    // 浅绿
            Color("Grass/1").opacity(0.85),      // 中深绿
            Color("Grass/2").opacity(0.9)        // 中浅绿
        ]
    )
    
    // 彩云主题
    static let fantasy = ColorTheme(
        name: "彩云",
        colors: [
            Color("Fantasy/1"),                  // 深紫
            Color("Fantasy/2"),                  // 浅粉
            Color("Fantasy/1").opacity(0.85),    // 中深紫
            Color("Fantasy/2").opacity(0.9)      // 中浅粉
        ]
    )
    
    // 日落主题
    static let sunset = ColorTheme(
        name: "日落",
        colors: [
            Color("Sunset/1"),                   // 深橙
            Color("Sunset/2"),                   // 浅橙
            Color("Sunset/1").opacity(0.85),     // 中深橙
            Color("Sunset/2").opacity(0.9)       // 中浅橙
        ]
    )
    
    static let allThemes: [ColorTheme] = [.ocean, .grass, .fantasy, .sunset]
}

// MARK: - Time Digit Model
struct TimeDigit: Identifiable {
    let id = UUID()
    let value: String
    let position: Int // 0-3 表示四个位置
}

// Provide a custom Equatable implementation for ColorTheme
extension ColorTheme {
    static func ==(lhs: ColorTheme, rhs: ColorTheme) -> Bool {
        return lhs.name == rhs.name
    }
}

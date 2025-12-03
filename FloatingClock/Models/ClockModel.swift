import SwiftUI

// MARK: - Color Theme Model
struct ColorTheme: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let primaryColor: Color
    let secondaryColor: Color
    
    // 生成渐变色系 - 增加颜色距离，深浅交错
    var gradientColors: [Color] {
        // 创建更明显的对比：深-浅-深-浅
        let colors = [
            primaryColor,
            Color.interpolate(from: primaryColor, to: secondaryColor, fraction: 0.25),
            Color.interpolate(from: primaryColor, to: secondaryColor, fraction: 0.55),
            Color.interpolate(from: primaryColor, to: secondaryColor, fraction: 0.85)
        ]
        
        // 重新排列实现深浅交错: 0(深), 3(浅), 1(中深), 2(中浅)
        return [colors[0], colors[3], colors[1], colors[2]]
    }
    
    // 冒号颜色 - 明亮色
    var colonColor: Color {
        return Color.white.opacity(0.95)
    }
    
    // 重叠部分颜色 - 不同的明亮色
    var overlapColor: Color {
        return Color.white.opacity(0.7)
    }
    
    static let `default` = ColorTheme(
        name: "默认",
        primaryColor: Color(red: 0.3, green: 0.4, blue: 0.6),
        secondaryColor: Color(red: 0.6, green: 0.7, blue: 0.9)
    )
    
    static let pink = ColorTheme(
        name: "粉紫",
        primaryColor: Color(red: 0.85, green: 0.3, blue: 0.5),
        secondaryColor: Color(red: 0.5, green: 0.3, blue: 0.95)
    )
    
    static let ocean = ColorTheme(
        name: "海洋",
        primaryColor: Color(red: 0.15, green: 0.4, blue: 0.75),
        secondaryColor: Color(red: 0.4, green: 0.75, blue: 0.95)
    )
    
    static let sunset = ColorTheme(
        name: "日落",
        primaryColor: Color(red: 0.85, green: 0.4, blue: 0.25),
        secondaryColor: Color(red: 0.95, green: 0.75, blue: 0.45)
    )
    
    static let allThemes: [ColorTheme] = [.default, .pink, .ocean, .sunset]
}

// MARK: - Time Digit Model
struct TimeDigit: Identifiable {
    let id = UUID()
    let value: String
    let position: Int // 0-3 表示四个位置
}

// MARK: - Color Extension
extension Color {
    static func interpolate(from: Color, to: Color, fraction: Double) -> Color {
        let fromComponents = UIColor(from).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(to).cgColor.components ?? [0, 0, 0, 1]
        
        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * fraction
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * fraction
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * fraction
        let a = fromComponents[3] + (toComponents[3] - fromComponents[3]) * fraction
        
        return Color(red: r, green: g, blue: b, opacity: a)
    }
}

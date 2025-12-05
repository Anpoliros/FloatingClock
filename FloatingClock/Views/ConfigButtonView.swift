import SwiftUI

struct ConfigButtonView: View {
    @Binding var selectedTheme: ColorTheme
    // 关键修改：将 showSettings 提升为 Binding，让父视图感知菜单开关状态
    @Binding var showSettings: Bool
    
    @ObservedObject private var config = FloatConfig.shared
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                showSettings.toggle()
            }
        }) {
            Image(systemName: "circle.fill")
                .font(.system(size: 35))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 45, height: 45)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        .overlay(alignment: .bottomTrailing) {
            if showSettings {
                ZStack(alignment: .bottomTrailing) {
                    // 1. 超大透明背景层 - 用于拦截点击以退出
                    Color.black.opacity(0.001)
                        .frame(width: 3000, height: 3000)
                        .offset(x: 1500, y: 1500)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showSettings = false
                            }
                        }
                    
                    // 2. 设置面板
                    settingsPanel
                        .offset(x: -65, y: 0)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.8, anchor: .bottomTrailing)),
                                removal: .opacity.combined(with: .scale(scale: 0.8, anchor: .bottomTrailing))
                            )
                        )
                }
            }
        }
    }
    
    private var settingsPanel: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 25) {
                // --- 布局调整部分 ---
                VStack(alignment: .leading, spacing: 15) {
                    Text("DISPLAY").font(.caption).bold().foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Scale")
                            Spacer()
                            Text("\(config.fontSizeRatio, specifier: "%.2f")")
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        Slider(value: $config.fontSizeRatio, in: 0.5...1.2)
                            .tint(.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Spread")
                            Spacer()
                            Text("\(config.spreadFactor, specifier: "%.2f")")
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        Slider(value: $config.spreadFactor, in: 0.5...1.5)
                            .tint(.white.opacity(0.8))
                    }
                    
                    // 动画风格开关
                    Toggle(isOn: Binding(
                        get: { config.animationStyle == .crossfade },
                        set: { isCrossfade in
                            config.animationStyle = isCrossfade ? .crossfade : .fly
                        }
                    )) {
                        HStack {
//                            Image(systemName: config.animationStyle == .crossfade ? "eye.fill" : "arrow.up.circle.fill")
//                                .foregroundColor(.white)
                            Text("是否淡入淡出")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: selectedTheme.gradientColors.first ?? .blue))
                    .padding(.horizontal, 4)
                }
                
                Divider().background(Color.white.opacity(0.2))
                
                
                
                // --- 主题选择部分 ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("THEME").font(.caption).bold().foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        ForEach(ColorTheme.allThemes) { theme in
                            ThemeRow(theme: theme, isSelected: selectedTheme.id == theme.id)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTheme = theme
                                }
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(width: 300)
        .frame(maxHeight: screenHeight * 0.8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Helper Views

struct ThemeRow: View {
    let theme: ColorTheme
    let isSelected: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: -5) {
                ForEach(theme.gradientColors.indices, id: \.self) { index in
                    Circle()
                        .fill(theme.gradientColors[index])
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
            }
            
            Text(theme.name)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.leading, 8)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.white.opacity(0.15) : Color.black.opacity(0.05))
        )
    }
}

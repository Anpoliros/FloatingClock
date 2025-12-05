//
//  ConfigButtonView.swift
//  FloatingClock
//
//  Created by anpoliros on 2025/12/5.
//

import SwiftUI

struct ConfigButtonView: View {
    @Binding var selectedTheme: ColorTheme
    @ObservedObject private var config = FloatConfig.shared
    @State private var showSettings = false
    
    // 获取屏幕尺寸以计算 80% 高度限制
    // 注意：在横屏模式下，UIScreen.main.bounds.height 通常是短边
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
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
        }
        // 使用 overlay 替代 fullScreenCover，彻底解决闪烁问题
        .overlay(alignment: .bottomTrailing) {
            if showSettings {
                ZStack(alignment: .bottomTrailing) {
                    // 1. 超大透明背景层 - 用于拦截点击以退出
                    // 使用 fixedSize 确保它足够大，能覆盖整个屏幕
                    Color.black.opacity(0.001)
                        .frame(width: 3000, height: 3000)
                        .offset(x: 1500, y: 1500) // 偏移中心点，确保覆盖各个方向
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showSettings = false
                            }
                        }
                    
                    // 2. 设置面板
                    settingsPanel
                        // 位置：按钮左侧，留出一点间距 (按钮宽50 + 间距10 + 自身宽度的一半偏移?)
                        // 这里使用 alignmentGuide 或 offset 更简单。
                        // 由于 overlay 对齐的是 bottomTrailing (按钮的位置)，
                        // 我们只需要向左偏移 (按钮宽度 50 + 间距 15)
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
                    
                    // 字体大小
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
                    
                    // 间距
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
        // 尺寸限制
        .frame(width: 300) // 固定宽度
        .frame(maxHeight: screenHeight * 0.8) // 高度自适应，但不超过屏幕高度的 80%
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Helper Views
// (ThemeRow 保持不变，无需重复粘贴，若原文件已包含可直接使用)
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

# iOS 浮动时钟应用

一个模仿 iOS 待机显示中浮动时钟效果的 SwiftUI 应用。

## 功能特点

### 1. 视觉效果
- **浮动数字**: 四位数字和一个冒号，采用大号圆润字体
- **层叠效果**: 数字之间有明显的交叠，冒号在最上层
- **智能居中**: 对于 9:41 这样的三位数时间，自动保持屏幕居中
- **颜色渐变**: 数字使用渐变色系，重叠部分显示特殊亮色

### 2. 动画效果
- **入场动画**: 新数字从下方浮起，带有气泡般的浮力效果
- **退场动画**: 旧数字向上飘离消失
- **持续漂移**: 每个数字围绕中心缓慢随机浮动，各自独立，避免视觉不协调
- **弹跳效果**: 数字到达位置后会向上弹跳一小段距离

### 3. 配色系统
提供四种预设配色方案：
- **默认**: 深蓝灰色和浅蓝灰色
- **粉紫**: 粉色和紫色渐变
- **海洋**: 深蓝和浅蓝渐变
- **日落**: 橙红和金黄渐变

## 项目结构

```
FloatingClock/
├── FloatingClockApp.swift          # 应用入口，设置横屏模式
├── Models/
│   └── ClockModel.swift            # 数据模型（颜色主题、时间数字）
└── Views/
    ├── Float.swift                 # 单个浮动数字视图组件
    └── ContentView.swift           # 主视图（时钟布局、主题选择）
```

## 技术实现

### MVC 架构
- **Model**: `ClockModel.swift` - 定义颜色主题和数据结构
- **View**: `Float.swift` 和 `ContentView.swift` - 负责 UI 渲染和动画
- **Controller**: 控制逻辑集成在 View 中（符合 SwiftUI 的设计模式）

### 核心技术
- **SwiftUI**: 使用最新的 SwiftUI 框架
- **兼容性**: 支持 iOS 17+
- **动画系统**: 使用 `.spring()` 动画和 `.easeInOut()` 实现流畅效果
- **定时器**: 使用 `Timer.publish()` 更新时间
- **几何布局**: 使用 `GeometryReader` 和 `ZStack` 实现精确布局

### 关键实现细节

#### 1. 浮动动画（Float.swift）
```swift
- 每个数字独立的浮动循环
- 随机延迟启动，避免同步
- 动态速度变化（6-10秒）
- 浮动范围：±30点
```

#### 2. 数字变化动画
```swift
- 旧数字向上退出（150点位移）
- 新数字从下方进入（100点位移）
- 到达后向上弹跳（15点弹跳）
- 使用弹簧动画模拟物理效果
```

#### 3. 颜色系统
```swift
- 基于两个基础色值生成渐变色系
- 使用颜色插值算法生成中间色
- 重叠部分使用 .screen 混合模式
- 冒号使用高亮白色
```

#### 4. 时间格式
```swift
- 使用 DateFormatter 格式化为 "H:mm"
- 自动处理单位数小时（无前导零）
- 逐字符解析实现独立数字动画
```

## 使用方法

### 1. 创建 Xcode 项目
1. 打开 Xcode，创建新项目
2. 选择 "App"，使用 SwiftUI
3. 设置项目名称为 "FloatingClock"

### 2. 导入文件
将以下文件复制到项目中：
- `FloatingClockApp.swift` → 项目根目录（替换默认的 App 文件）
- `Models/ClockModel.swift` → Models 文件夹
- `Views/Float.swift` → Views 文件夹
- `Views/ContentView.swift` → Views 文件夹（替换默认的 ContentView）

### 3. 配置项目设置
在 Xcode 中：
1. 选择项目 → Target → General
2. 在 "Deployment Info" 中：
   - 取消勾选 "Portrait"
   - 只勾选 "Landscape Left" 和 "Landscape Right"
3. 设置最低支持版本为 iOS 17.0

### 4. 运行
- 在模拟器或真机上运行
- 点击右下角的调色板按钮切换主题
- 应用会自动横屏显示

## 自定义配色

要添加新的配色方案，在 `ClockModel.swift` 中添加：

```swift
static let myTheme = ColorTheme(
    name: "我的主题",
    primaryColor: Color(red: 0.x, green: 0.y, blue: 0.z),
    secondaryColor: Color(red: 0.x, green: 0.y, blue: 0.z)
)
```

然后将其添加到 `allThemes` 数组中。

## 注意事项

1. **性能优化**: 浮动动画使用了递归调用，但通过随机延迟避免了同步问题
2. **内存管理**: 定时器在视图消失时会自动取消
3. **横屏锁定**: 通过 AppDelegate 实现强制横屏
4. **状态栏隐藏**: 使用 `.persistentSystemOverlays(.hidden)` 完全隐藏

## 系统要求

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 许可证

本项目为演示代码，可自由使用和修改。

# Godot 制作全屏覆盖菜单（不切换场景）

在 Godot 中，如果你想制作一个菜单（例如暂停菜单、设置页面），但不希望切换场景（即保持当前游戏状态可见），最好的做法是使用 **CanvasLayer** 和 **ColorRect**。

## 1. 核心概念

*   **CanvasLayer**: 用于将 UI 渲染在独立的层级上。默认情况下，UI 会跟随摄像机移动，而 `CanvasLayer` 可以确保 UI 始终固定在屏幕最前方，且其 `layer` 属性决定了遮盖顺序。
*   **ColorRect (遮罩/调暗背景)**: 一个铺满全屏的半透明矩形，通过设置它的颜色（如黑色，Alpha 值为 100 左右）来实现“背景变灰”的效果。
*   **Process Mode (暂停处理)**: 当游戏暂停时 (`get_tree().paused = true`)，默认所有节点都会停止运行。我们需要将菜单节点的 `Process Mode` 设置为 `Always`，这样即使游戏暂停，菜单依然可以响应输入。

## 2. 节点层级结构

建议的结构如下：

*   `CanvasLayer` (设置 `layer = 10` 确保在最上方)
    *   `Control` (根节点，改名为 `OverlayMenu`)
        *   `ColorRect` (背景遮罩，设置 `Anchors Preset` 为 `Full Rect`)
        *   `CenterContainer` (居中容器，设置 `Anchors Preset` 为 `Center`)
            *   `PanelContainer` (菜单主体背景)
                *   `VBoxContainer` (垂直排列按钮)
                    *   `Label` (标题)
                    *   `Button` (继续)
                    *   `Button` (退出)

## 3. 实现步骤

### A. 设置遮罩
1.  选中 `ColorRect`。
2.  在 `Layout` (布局) 选项中选择 `Anchors Preset` -> `Full Rect`。
3.  在 `Color` 属性中选择一个深灰色或黑色，并将 **A (Alpha)** 通道设置为 128 左右（半透明）。

### B. 设置暂停模式
这是最关键的一步，否则你暂停游戏后就没法点菜单了。
1.  选中 `OverlayMenu` 节点。
2.  在属性面板中找到 `Process` -> `Mode`。
3.  将其设置为 **Always** (始终)。

### C. 编写脚本
给 `OverlayMenu` 挂载如下脚本：

```gdscript
extends Control

func _ready():
	# 初始隐藏菜单
	hide()

func _input(event):
	# 按下 Esc 键切换菜单状态
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()

func toggle_menu():
	visible = !visible
	# 根据菜单可见性暂停或恢复游戏
	get_tree().paused = visible

	if visible:
		# 可以在这里播放打开菜单的音效或动画
		pass

func _on_resume_button_pressed():
	toggle_menu()

func _on_quit_button_pressed():
	get_tree().quit()
```

## 4. 为什么不切换场景？

*   **性能**: 不需要重新加载资源，打开速度极快。
*   **状态保持**: 玩家的坐标、生命值、怪物位置等都完美保留，因为它们只是被“暂停”了，并没有被销毁。
*   **视觉效果**: 通过调整 `ColorRect` 的 Alpha 值，你可以精确控制背景的昏暗程度，营造出悬浮窗的感觉。

## 5. 进阶：模糊背景

如果你使用的是 Godot 4，想要实现背景模糊而不仅仅是变灰：
1.  创建一个 `BackBufferCopy` 节点（设置模式为 `Viewport`）。
2.  在它下面放一个 `ColorRect`。
3.  给这个 `ColorRect` 编写一个简单的 Shader 材质，读取 `SCREEN_TEXTURE` 并进行高斯模糊处理。

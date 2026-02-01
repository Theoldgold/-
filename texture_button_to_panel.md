# Godot 教程：点击 TextureButton 显示/切换 Panel

在 Godot 中，点击按钮来显示一个面板（Panel）或菜单是最基础的 UI 交互。以下是实现这一功能的几种常见方法。

## 1. 基础概念

*   **TextureButton**: 带有图片的按钮。
*   **Panel / PanelContainer**: UI 面板容器。
- **visible 属性**: 控制节点是否显示。
- **pressed 信号**: 当按钮被点击时发出的信号。

---

## 方法 1：使用编辑器（无需编写代码，最简单）

如果你只需要点击按钮后直接显示面板，可以利用 Godot 的“连接信号”功能。

1.  在场景中选中你的 `TextureButton`。
2.  在右侧面板切换到 **“节点 (Node)”** 标签页，双击 **`pressed()`** 信号。
3.  在弹出的窗口中，选择你的 **`Panel`** 节点。
4.  在下方的 **“方法内容 (Method In Node)”** 中，如果你只想让它显示，可以手动连接到 `show` 方法。
    *   *注意：如果下拉列表里没有 `show`，你可以连接到一个脚本函数（见方法 2）。*

---

## 方法 2：使用脚本（推荐，最灵活）

这是最通用的做法，可以实现“点击打开”、“点击关闭”或“点击切换（Toggle）”。

### 步骤 A：准备场景
确保你的 `Panel` 默认是隐藏的（在属性检查器中取消勾选 `Visible`）。

### 步骤 B：编写脚本
给你的根节点（或者按钮本身）挂载以下代码：

```gdscript
extends Control

# 在编辑器中将你的 Panel 拖拽到这个变量上
@export var target_panel: Panel

func _on_texture_button_pressed():
	# 简单的显示
	target_panel.show()

	# 或者：切换显示/隐藏状态
	# target_panel.visible = !target_panel.visible
```

### 步骤 C：连接信号
1.  选中 `TextureButton`。
2.  在 **“节点”** 标签页双击 **`pressed()`**。
3.  选择挂载了上述脚本的节点。
4.  选择对应的函数（例如 `_on_texture_button_pressed`）。

---

## 方法 3：全代码实现（动态生成或纯代码流）

如果你不想在编辑器里连线，可以在脚本的 `_ready()` 函数里完成连接：

```gdscript
extends Control

@onready var my_button = $TextureButton
@onready var my_panel = $Panel

func _ready():
	# 使用 Godot 4 的 Lambda 表达式语法
	my_button.pressed.connect(func(): my_panel.visible = !my_panel.visible)
```

---

## 进阶提示

1.  **动画效果**: 使用 `Tween` 可以让面板平滑弹出，而不是瞬间出现。
    ```gdscript
    func toggle_panel():
        var tween = create_tween()
        if my_panel.visible:
            # 缩小并隐藏
            tween.tween_property(my_panel, "scale", Vector2.ZERO, 0.2)
            tween.finished.connect(my_panel.hide)
        else:
            my_panel.show()
            my_panel.scale = Vector2.ZERO
            tween.tween_property(my_panel, "scale", Vector2.ONE, 0.2)
    ```
2.  **独占模式**: 如果是弹出菜单，可能需要阻止点击背景，可以设置 Panel 的 `Mouse > Filter` 属性为 `Stop`。
3.  **暂停游戏**: 如果是暂停菜单，别忘了参考 `overlay_menu_tutorial.md` 中关于 `Process Mode` 的设置。

# Godot 如何使用 TextureButton 切换不同的 Panel

在制作游戏 UI 时，经常需要点击不同的按钮来切换不同的界面（例如：点击“设置”显示设置面板，点击“库存”显示背包面板）。

## 1. 场景结构建议

为了方便管理，建议将所有面板放在同一个容器下，并使用一个脚本统一控制。

*   `CanvasLayer` 或 `Control` (根节点)
    *   `HBoxContainer` (按钮栏)
        *   `TextureButton_Settings`
        *   `TextureButton_Inventory`
        *   `TextureButton_Skills`
    *   `Control` (面板容器，改名为 `PanelContainer`)
        *   `Panel_Settings` (设置面板)
        -   `Panel_Inventory` (背包面板)
        -   `Panel_Skills` (技能面板)

## 2. 核心逻辑

切换面板的核心逻辑非常简单：
1.  **隐藏**所有面板。
2.  **显示**目标面板。

## 3. 代码实现

你可以将以下脚本挂载到根节点或一个专门的管理器节点上。

### 方法 A：手动连接信号 (简单直观)

```gdscript
extends Control

@onready var settings_panel = $PanelContainer/Panel_Settings
@onready var inventory_panel = $PanelContainer/Panel_Inventory
@onready var skills_panel = $PanelContainer/Panel_Skills

func _ready():
    # 初始状态：只显示第一个，或者全部隐藏
    _hide_all_panels()
    inventory_panel.show()

func _hide_all_panels():
    settings_panel.hide()
    inventory_panel.hide()
    skills_panel.hide()

func _on_settings_button_pressed():
    _hide_all_panels()
    settings_panel.show()

func _on_inventory_button_pressed():
    _hide_all_panels()
    inventory_panel.show()

func _on_skills_button_pressed():
    _hide_all_panels()
    skills_panel.show()
```

### 方法 B：动态索引方式 (更具扩展性)

如果你的面板很多，可以使用数组和索引来管理。

```gdscript
extends Control

@export var panels: Array[Control]

func _ready():
    # 隐藏所有面板
    for p in panels:
        p.hide()

    # 默认显示第一个
    if panels.size() > 0:
        show_panel(0)

func show_panel(index: int):
    for i in range(panels.size()):
        panels[i].visible = (i == index)
```

## 4. 进阶：使用 TabContainer

如果你不需要自定义按钮的复杂样式，Godot 内置的 `TabContainer` 是最简单的方案。它会自动处理按钮点击和面板切换。

1.  添加一个 `TabContainer` 节点。
2.  将你的各个 `Panel` 节点作为 `TabContainer` 的子节点。
3.  `TabContainer` 会自动根据子节点的名称生成标签页。

## 5. 常见问题

*   **按钮没反应？** 检查 `TextureButton` 的 `pressed` 信号是否正确连接到了脚本。
*   **面板重叠？** 确保所有面板都在同一个位置（通常使用 `Full Rect` 布局），并且同一时间只有一个是可见的。
*   **遮挡问题？** UI 节点的显示顺序由它们在场景树中的顺序决定，靠下的节点会覆盖靠上的节点。

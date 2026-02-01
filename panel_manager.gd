# panel_manager.gd
# 这是一个用于在同一 UI 下切换不同面板的通用脚本
# 使用方法：
# 1. 将此脚本挂载到包含多个面板的父节点或根节点上。
# 2. 在检查器（Inspector）中将需要切换的面板添加到 `panels` 数组中。
# 3. 将按钮的 `pressed` 信号连接到 `show_panel` 函数，并传入对应的索引。

extends Control

## 在编辑器中指定需要管理的面板
@export var panels: Array[Control] = []

## 初始显示的面板索引 (-1 表示全部隐藏)
@export var initial_index: int = 0

## 是否在切换时使用简单的淡入动画
@export var use_transitions: bool = true

func _ready() -> void:
	# 初始化：隐藏所有面板并显示初始面板
	_initialize_panels()

func _initialize_panels() -> void:
	for i in range(panels.size()):
		if panels[i]:
			if i == initial_index:
				panels[i].show()
				panels[i].modulate.a = 1.0
			else:
				panels[i].hide()
				panels[i].modulate.a = 0.0

## 切换到指定索引的面板
## 可以在编辑器信号连接中直接调用，设置参数为对应的整数
func show_panel(index: int) -> void:
	if index < 0 or index >= panels.size():
		push_warning("Panel index out of bounds: ", index)
		return

	for i in range(panels.size()):
		var panel = panels[i]
		if not panel: continue

		if i == index:
			_fade_in(panel)
		else:
			_fade_out(panel)

func _fade_in(node: Control) -> void:
	node.show()
	if use_transitions:
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
	else:
		node.modulate.a = 1.0

func _fade_out(node: Control) -> void:
	if not node.visible:
		return

	if use_transitions:
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE)
		tween.finished.connect(node.hide)
	else:
		node.modulate.a = 0.0
		node.hide()

## 辅助方法：通过名称显示面板
func show_panel_by_name(panel_name: String) -> void:
	for i in range(panels.size()):
		if panels[i] and panels[i].name == panel_name:
			show_panel(i)
			return
	push_warning("Panel with name not found: ", panel_name)

extends Control

## 一个通用的全屏覆盖菜单脚本 (Overlay Menu)
## 适用于暂停菜单、设置页面等。
## 确保该节点的 Process -> Mode 设置为 "Always"

@export var pause_game: bool = true

func _ready() -> void:
	# 确保菜单在开始时是隐藏的
	hide()

	# 如果没有在编辑器中连接，手动连接按钮信号 (假设子节点名称)
	var resume_btn = find_child("ResumeButton")
	if resume_btn:
		resume_btn.pressed.connect(toggle_menu)

	var quit_btn = find_child("QuitButton")
	if quit_btn:
		quit_btn.pressed.connect(func(): get_tree().quit())

func _input(event: InputEvent) -> void:
	# 监听 ui_cancel (通常是 Esc 键)
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()

func toggle_menu() -> void:
	visible = !visible

	if pause_game:
		# 设置整个场景树的暂停状态
		get_tree().paused = visible

	# 释放焦点，防止按钮一直保持高亮
	if not visible:
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

func show_menu() -> void:
	if not visible:
		toggle_menu()

func hide_menu() -> void:
	if visible:
		toggle_menu()

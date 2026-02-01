# button_to_panel.gd
# 挂载到一个 TextureButton 上，用于控制另一个 Panel 的显示
# 或者挂载到父节点上并手动配置变量

extends Control

## 目标面板的引用
@export var target_panel: Control

## 行为模式
enum Mode {
	SHOW_ONLY,  ## 仅显示
	HIDE_ONLY,  ## 仅隐藏
	TOGGLE      ## 切换显示/隐藏
}

@export var mode: Mode = Mode.TOGGLE

## 是否使用动画过渡
@export var use_animation: bool = true
@export var animation_duration: float = 0.2

func _ready() -> void:
	# 如果这个脚本直接挂载在 TextureButton 上，尝试自动连接信号
	if self is TextureButton:
		self.pressed.connect(_on_pressed)
	else:
		# 否则，尝试寻找名为 "TextureButton" 的子节点
		var btn = find_child("TextureButton")
		if btn and btn is TextureButton:
			btn.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if not target_panel:
		push_warning("ButtonToPanel: 未指定 target_panel")
		return

	match mode:
		Mode.SHOW_ONLY:
			_set_panel_visible(true)
		Mode.HIDE_ONLY:
			_set_panel_visible(false)
		Mode.TOGGLE:
			_set_panel_visible(!target_panel.visible)

func _set_panel_visible(is_show: bool) -> void:
	if not use_animation:
		target_panel.visible = is_show
		return

	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if is_show:
		target_panel.show()
		target_panel.modulate.a = 0
		target_panel.scale = Vector2(0.9, 0.9)
		# 并行播放透明度和缩放动画
		tween.parallel().tween_property(target_panel, "modulate:a", 1.0, animation_duration)
		tween.parallel().tween_property(target_panel, "scale", Vector2.ONE, animation_duration)
	else:
		tween.parallel().tween_property(target_panel, "modulate:a", 0.0, animation_duration)
		tween.parallel().tween_property(target_panel, "scale", Vector2(0.9, 0.9), animation_duration)
		tween.finished.connect(target_panel.hide)

## 外部调用接口
func show_panel() -> void:
	_set_panel_visible(true)

func hide_panel() -> void:
	_set_panel_visible(false)

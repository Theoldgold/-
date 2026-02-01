# one_image_button.gd
# 这是一个演示如何只用一张图通过脚本控制 TextureButton 状态的示例
# 使用方法：将此脚本挂载到 TextureButton 节点上

extends TextureButton

## 状态颜色配置
@export var color_normal: Color = Color.WHITE
@export var color_hover: Color = Color(1.2, 1.2, 1.2)  # 稍微变亮
@export var color_pressed: Color = Color(0.7, 0.7, 0.7) # 稍微变暗
@export var color_disabled: Color = Color(0.3, 0.3, 0.3) # 灰色

func _ready() -> void:
	# 确保按钮只有一张 Normal 图片也能有视觉反馈
	# 初始化显示
	_update_visuals()

	# 连接基础按钮信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	if not disabled:
		# 使用 Tween 实现平滑过渡效果
		create_tween().tween_property(self, "self_modulate", color_hover, 0.1)

func _on_mouse_exited() -> void:
	if not disabled:
		create_tween().tween_property(self, "self_modulate", color_normal, 0.1)

func _on_button_down() -> void:
	if not disabled:
		self_modulate = color_pressed

func _on_button_up() -> void:
	if not disabled:
		if is_hovered():
			self_modulate = color_hover
		else:
			create_tween().tween_property(self, "self_modulate", color_normal, 0.1)

# 手动更新视觉状态
func _update_visuals() -> void:
	if disabled:
		self_modulate = color_disabled
	else:
		self_modulate = color_normal

# 覆盖禁用属性以更新视觉
func set_disabled(p_disabled: bool) -> void:
	super.set_disabled(p_disabled)
	_update_visuals()

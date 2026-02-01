# Godot TextureButton 单图实现多状态教程

在 Godot 中，如果你想只用一张图片就实现 `TextureButton` 的不同状态（普通、按下、悬停等），通常有以下三种主要方法：

## 方法 1：使用 AtlasTexture (编辑器最常用)

如果你的“一张图”其实是一个**精灵图集 (Sprite Sheet)**，即一张大图里包含了按钮的所有状态。

1.  在 `TextureButton` 的 `Texture > Normal` 属性中，选择 `新建 AtlasTexture`。
2.  点击刚创建的 `AtlasTexture`，在 `Atlas` 属性中加载你的那张大图。
3.  点击 `Edit Region`（编辑区域），框选出对应“普通状态”的矩形区域。
4.  对 `Pressed`、`Hover` 等其他状态重复上述步骤，加载同一张大图，但框选不同的区域。

---

## 方法 2：使用脚本与自调制 (Modulate)

如果你的“一张图”真的只有**一个图标**，你想通过改变颜色或亮度来区分状态。

你可以编写一个简单的脚本，监听按钮的信号并修改 `self_modulate` 属性：

```gdscript
extends TextureButton

# 定义不同状态的颜色
@export var normal_color = Color(1, 1, 1)      # 原色
@export var hover_color = Color(1.2, 1.2, 1.2)   # 变亮 (悬停)
@export var pressed_color = Color(0.8, 0.8, 0.8) # 变暗 (按下)

func _ready():
	# 初始化颜色
	self_modulate = normal_color

	# 连接信号 (Godot 4.x 语法)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_mouse_entered():
	self_modulate = hover_color

func _on_mouse_exited():
	self_modulate = normal_color

func _on_button_down():
	self_modulate = pressed_color

func _on_button_up():
	if is_hovered():
		self_modulate = hover_color
	else:
		self_modulate = normal_color
```

---

## 方法 3：使用着色器 (Shader)

如果你想要更高级的效果（例如禁用状态变成灰色），可以使用 `CanvasItem` 着色器。

1.  在 `CanvasItem > Material` 中新建 `ShaderMaterial`。
2.  新建 `Shader` 并输入以下代码：

```shader
shader_type canvas_item;

uniform bool is_pressed = false;
uniform bool is_hovered = false;
uniform bool is_disabled = false;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    if (is_disabled) {
        float avg = (color.r + color.g + color.b) / 3.0;
        color.rgb = vec3(avg);
    } else if (is_pressed) {
        color.rgb *= 0.8; // 按下变暗
    } else if (is_hovered) {
        color.rgb *= 1.2; // 悬停变亮
    }

    COLOR = color;
}
```

3.  在脚本中根据按钮状态更新着色器的 `uniform` 变量。

---

### 总结
- 如果图片包含多个状态切片：用 **AtlasTexture**。
- 如果想简单通过变色实现：用 **脚本修改 Modulate**。
- 如果需要复杂视觉特效：用 **Shader**。

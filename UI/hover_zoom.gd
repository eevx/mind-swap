extends Node
class_name hover_zoom

var button: BaseButton
var zoom_tween: Tween

@export var zoom_amount := 1.2

func _ready() -> void:
	if get_parent() is BaseButton:
		button = get_parent()
		button.mouse_entered.connect(_on_mouse_entered)
		button.mouse_exited.connect(_on_mouse_exited)

		if button is Control:
			button.pivot_offset = button.size / 2
		else:
			printerr("hover_zoom expects a Control-derived button")
			queue_free()
	else:
		printerr("hover_zoom must be a child of a BaseButton")
		queue_free()

func _on_mouse_entered() -> void:
	SfxManager.play_sfx("hover", -10., randf_range(0.9, 1.1))
	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.tween_property(button, "scale", Vector2.ONE * zoom_amount, 0.3) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if zoom_tween:
		zoom_tween.kill()
	button.scale = Vector2.ONE

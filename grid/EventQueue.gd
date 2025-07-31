class_name EventQueue
var queue: Array = []

func enqueue(effect_callable: Callable) -> void:
	queue.append(effect_callable)

func process_all() -> void:
	while queue.size() > 0:
		var effect = queue.pop_front()
		effect.call()

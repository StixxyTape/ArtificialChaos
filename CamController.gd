extends Camera2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Zoom In"):
		zoom *= 1.2
	if Input.is_action_just_pressed("Zoom Out"):
		zoom /= 1.2

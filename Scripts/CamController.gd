extends Camera2D

func ZoomOut():
	zoom /= 1.2
func ZoomIn():
	zoom *= 1.2

func Move(direction : Vector2):
	var speed : int = 5
	if Input.is_action_pressed("Run"):
		speed = 12
	position += direction * speed

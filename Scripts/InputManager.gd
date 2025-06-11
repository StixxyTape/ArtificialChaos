extends Node2D

@onready var cam : Camera2D = get_node("../Camera2D")
@onready var troopGenerator : Node = get_node("../TroopSpawner")

signal zoomOut 
signal zoomIn

signal leftClick

signal moveCamera

func _ready() -> void:
	zoomOut.connect(cam.ZoomOut)
	zoomIn.connect(cam.ZoomIn)
	moveCamera.connect(cam.Move)
		
	leftClick.connect(troopGenerator.GenerateTroop)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Zoom In"):
		zoomIn.emit()
	if Input.is_action_just_pressed("Zoom Out"):
		zoomOut.emit()
	if Input.get_vector("Left", "Right", "Up", "Down") != Vector2.ZERO:
		moveCamera.emit(Input.get_vector("Left", "Right", "Up", "Down"))#
	
	if Input.is_action_just_pressed("Left Click"):
		leftClick.emit(get_global_mouse_position())
	

extends Node

@onready var troopPrefab : PackedScene = preload("res://Scenes/Troop.tscn")
@onready var spawnParticles : PackedScene = preload("res://Scenes/SpawnParticles.tscn")

func GenerateTroop(pos : Vector2):
	var newSpawnParticles : CPUParticles2D = spawnParticles.instantiate()
	newSpawnParticles.position = pos
	newSpawnParticles.emitting = true
	add_child(newSpawnParticles)
	
	print("Spawning troop")
	
	var new_troop : Control = troopPrefab.instantiate()
	new_troop.position = pos
	add_child(new_troop)
	

extends Node

# A dictionary to hold all our categorized word lists
var word_data: Dictionary = {}

func _ready():
	_load_dictionary("res://dictionary.json")
	print(generate_sprite_prompt())
	
func _load_dictionary(file_path: String):
	if not FileAccess.file_exists(file_path):
		print("Error: Dictionary file not found at ", file_path)
		return
	
	# Open the file and read all the text
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	
	# Use Godot's built-in JSON parser
	var json_object = JSON.parse_string(content)

	if typeof(json_object) == TYPE_DICTIONARY:
		word_data = json_object
		print("Successfully loaded dictionary with categories: ", word_data.keys())
	else:
		print("Error: Failed to parse JSON file.")

func get_random_word_from(category: String) -> String:
	if not word_data.has(category):
		return "BadCategory"
	
	var category_list: Array = word_data[category]
	if category_list.is_empty():
		return "EmptyCategory"
		
	return category_list.pick_random()

# Example of how you'd build a structured prompt
func generate_sprite_prompt() -> Array:
	var descriptor = get_random_word_from("descriptor")
	var subject = get_random_word_from("subject")
	
	print("Generated Sprite Prompt: ", [descriptor, subject])
	#return ["a brown-skinned, skinny, angry, feeble curry muncher ", "man holding a gift card"]
	return [descriptor, subject]

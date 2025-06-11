extends Node

@onready var adjectiveChoiceList : VBoxContainer = $CanvasLayer/WordChoiceList/WordChoiceColumns/AdjectiveList
@onready var nounChoiceList : VBoxContainer = $CanvasLayer/WordChoiceList/WordChoiceColumns/NounList

@onready var selectedAdjectiveList : VBoxContainer = $CanvasLayer/SelectedWordList/AdjectiveList
@onready var selectedNounList : VBoxContainer = $CanvasLayer/SelectedWordList/NounList

@onready var troopSpawner : Node =  get_node("../TroopSpawner")

# A dictionary to hold all our categorized word lists
var word_data: Dictionary = {}

func _ready():
	_load_dictionary("res://dictionary.json")
	generate_random_words()
	
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
	var adjectives = selectedAdjectiveList.get_children()
	var nouns = selectedNounList.get_children()
	
	if len(adjectives) == 0 or len(nouns) == 0:
		return []
	
	var adjectiveSentence : String = ""
	var nounSentence : String = ""
	for adjective in adjectives:
		adjectiveSentence += adjective.text
		if adjectives.find(adjective) != len(adjectives) - 1:
			adjectiveSentence += ", "
		else:
			adjectiveSentence += " "
			
		adjective.queue_free()
	for noun in nouns:
		nounSentence += noun.text
		if nouns.find(noun) != len(nouns) - 1:
			nounSentence += " "
		noun.queue_free()
		
	for adjective in adjectiveChoiceList.get_children():
		adjective.queue_free()
	for noun in nounChoiceList.get_children():
		noun.queue_free()
		
	print("Generated Sprite Prompt: ", [adjectiveSentence, nounSentence])
	
	generate_random_words()

	#return ["skinny, lean, ginger, wearing glasses", "watching anime"]
	return [adjectiveSentence, nounSentence]

func generate_random_words():
	for i in range(3):
		var adjective = get_random_word_from("adjective")
		var noun = get_random_word_from("noun")
		
		create_noun_button(noun)
		create_adjective_button(adjective)
	
func create_noun_button(buttonText : String, selected : bool = false) -> Button:
	var newButton : Button = Button.new()
	newButton.text = buttonText
	newButton.pressed.connect(newButton.queue_free)
	newButton.pressed.connect(create_noun_button.bind(buttonText, !selected))
	newButton.pressed.connect(word_limit_check)
	
	if !selected:
		nounChoiceList.add_child(newButton)
	else:
		selectedNounList.add_child(newButton)
	
	return newButton

func create_adjective_button(buttonText : String, selected : bool = false) -> Button:
	var newButton : Button = Button.new()
	newButton.text = buttonText
	newButton.pressed.connect(newButton.queue_free)
	newButton.pressed.connect(create_adjective_button.bind(buttonText, !selected))
	newButton.pressed.connect(word_limit_check)

	if !selected:
		adjectiveChoiceList.add_child(newButton)
	else:
		selectedAdjectiveList.add_child(newButton)

	return newButton
	
func word_limit_check():
	await get_tree().process_frame
		
	print(len(selectedNounList.get_children()) + len(selectedAdjectiveList.get_children()))
	if (len(selectedNounList.get_children()) + len(selectedAdjectiveList.get_children()) >= 3):
		for child in nounChoiceList.get_children():
			child.disabled = true
		for child in adjectiveChoiceList.get_children():
			child.disabled = true
	else:
		for child in nounChoiceList.get_children():
			child.disabled = false
		for child in adjectiveChoiceList.get_children():
			child.disabled = false

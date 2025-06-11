extends Control

@onready var http_request = $APIRequest
@onready var word_generator = get_node("../../WordGenerator")

@onready var sprite_container = $Sprite
@onready var texture_rect = $Sprite/ImageDisplay
@onready var health_bar = $Sprite/StatBox/StatList/HealthBar
@onready var damage_bar = $Sprite/StatBox/StatList/DamageBar
@onready var speed_bar = $Sprite/StatBox/StatList/SpeedBar
@onready var cloud_particles = $Sprite/CloudParticles

var server_url = "https://ai-image-service-814189234711.us-central1.run.app/generate_asset"
var image_size : int = 1024

var llm_prompt_template = """
You are a data-focused video game balance designer. Your task is to analyze a character concept and generate its core statistics as a JSON object.

The stats must be balanced on a scale from 1 to 100. A character strong in one area should be weaker in another. For example, a slow, armored character should have high health but low speed. A fragile, magical character might have high damage but low health.

Your response MUST be ONLY the raw JSON object, with no other text, explanations, or introductory sentences before or after it. Do NOT wrap the JSON in Markdown code fences. 

The JSON object must contain exactly three integer keys: "health", "damage", "speed", and "size".

Here are some examples of the expected input and output:

Input: "armored knight"
Output:
{
  "health": 83,
  "damage": 67,
  "speed": 22,
  "size": 25
}

Input: "ethereal wizard"
Output:
{
  "health": 16,
  "damage": 95,
  "speed": 34,
  "size": 20
}

Input: "cybernetic ninja"
Output:
{
  "health": 61,
  "damage": 79,
  "speed": 90,
  "size": 22
}

Input: "giant lizard monster"
Output:
{
  "health": 94,
  "damage": 91,
  "speed": 5,
  "size": 85
}

Input: "baby squirrel"
Output:
{
  "health": 3,
  "damage": 2,
  "speed": 10,
  "size": 1
}

Input: "{descriptor} {subject}"
Output:
"""

func _ready() -> void:
	send_api_request()

func send_api_request():
	var description = word_generator.generate_sprite_prompt()
	if description.is_empty():
		print("Prompt is empty!")
		return
		
	var image_prompt = "A full character shot of a "
	image_prompt += description[0] + description[1]
	image_prompt += ", orthographic view, anime style, pure white background"
	
	var stats_prompt = llm_prompt_template.format({
		"descriptor": description[0],
		"subject": description[1]
	})
	
	print("Sending request to server for prompt: ", image_prompt)
	print("Sending image size: ", str(image_size))
	print("Sending descriptor: ", description)
		
	# --- UPDATED LINE ---
	# Add the "image_size" key to the dictionary
	var body = JSON.stringify({
		"image_prompt": image_prompt,
		"stats_prompt": stats_prompt,
		"image_size": image_size 
	})
	
	var headers = ["Content-Type: application/json"]
	
	http_request.request(server_url, headers, HTTPClient.METHOD_POST, body)

func _on_api_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Asset data received successfully!")
		
		# First, parse the main JSON response
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		
		if json_data == null:
			print("Error: Failed to parse JSON response from server.")
			return

		# --- HANDLE THE STATS ---
		var stats = json_data.get("stats")
		if stats != null:
			print("Received Stats -- Health: %d, Damage: %d, Speed: %d, Size: %d" % [stats.health, stats.damage, stats.speed, stats.size])
		
		# --- HANDLE THE IMAGE ---
		var image_base64_string = json_data.get("image_base64")
		if image_base64_string != null:
			# Godot has built-in tools to convert Base64 back to raw bytes
			var image_bytes = Marshalls.base64_to_raw(image_base64_string)

			var image = Image.new()
			var error = image.load_png_from_buffer(image_bytes)

			if error == OK:
				var texture = ImageTexture.create_from_image(image)
				texture_rect.texture = texture
				print("Texture updated.")
			else:
				print("Error: Could not load image from Base64 data.")
		
		update_character(stats)
			
	else:
		print("An error occurred! Server responded with code: ", response_code)
		print("Server error message: ", body.get_string_from_utf8())

func update_character(stats):
	sprite_container.visible = true
	
	sprite_container.scale = Vector2(stats.size, stats.size) / 100
	
	cloud_particles.scale_amount_min = sprite_container.scale.x
	cloud_particles.scale_amount_max = sprite_container.scale.x
	cloud_particles.emitting = true

	await cloud_particles.finished
			
	# Now you can use these stats to update your game character!#
	var tween : Tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(health_bar, "value", int(stats.health), 3.0)
	tween.tween_property(damage_bar, "value", int(stats.damage), 3.0)
	tween.tween_property(speed_bar, "value", int(stats.speed), 3.0)

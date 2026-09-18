extends Control

# End scenes images
@export_group("End scenes")
@export var END_SCENE_BET_WIN: Texture2D = null
@export var END_SCENE_BET_LOSE: Texture2D = null
@export var END_SCENE_SELL: Texture2D = null
@export var END_SCENE_AUGUST: Texture2D = null
@export var END_SCENE_BILLIE: Texture2D = null
@export var END_SCENE_FRANCIS: Texture2D = null

func _ready() -> void:
	var end_scene: Node = self

	var scene_image: TextureRect = end_scene.get_node("Image")
	var scene_text: Label = end_scene.get_node("Text")


	match Global.selected_npc:
		0:
			_show_score(scene_text, 4000)
			scene_image.texture = END_SCENE_AUGUST
		1:
			_show_score(scene_text, 7000)
			scene_image.texture = END_SCENE_BILLIE
		2:
			_show_score(scene_text, 11000)
			scene_image.texture = END_SCENE_FRANCIS
		3:
			if Global.sold_ring:
				scene_image.texture = END_SCENE_SELL
				_show_score(scene_text, 1000)

			else:
				var rand_num: int = ((randi() % 100) as float/100)**15 * 50000 as int
				print_debug("Bet result: " + str(rand_num))
				if rand_num > 53859:
					rand_num = 53859

				_show_score(scene_text, rand_num)

				if rand_num > 7000:
					scene_image.texture = END_SCENE_BET_WIN
				else:
					scene_image.texture = END_SCENE_BET_LOSE

func _show_score(label: Label, score: int):
	label.text = str((score / 1000) as int) + "K" 

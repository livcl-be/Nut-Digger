extends Node2D

@onready var question_label: Label = $Question
@onready var npc_image: Sprite2D = $NPC

# Images of npc's
@export var NPC_1_IMAGE: Texture2D = null
@export var NPC_2_IMAGE: Texture2D = null
@export var NPC_3_IMAGE: Texture2D = null

var selected_npc: int = 0
var dialog_progress = [0, 0, 0]

const dialog: Array[Variant] = [
	{
		"name": "NPC 0",
		"introduction": ["Hallo mijn naam is npc 1"],
		"questions": ["Wat is je naam", "Hoe groot ben je"],
		"answers": [["Noor", "Liv", "Lucy"], ["1m23", "6 voeten", "de lengte van een fiat 500"]],
		"correct_answers": [0, 2],
		"proposal": ["TBD"],
	},

	{
		"name": "NPC 0",
		"introduction": ["Hallo mijn naam is npc 2"],
		"questions": ["Wat is je naam", "Hoe groot ben je"],
		"answers": [["Noor", "Liv", "Lucy"], ["1m23", "6 voeten", "de lengte van een fiat 500"]],
		"proposal": ["TBD"],
	},

	{
		"name": "NPC 0",
		"introduction": ["Hallo mijn naam is npc 3"],
		"questions": ["Wat is je naam", "Hoe groot ben je"],
		"answers": [["Noor", "Liv", "Lucy"], ["1m23", "6 voeten", "de lengte van een fiat 500"]],
		"proposal": ["TBD"],
	},
]

func _ready() -> void:
	match selected_npc:
		0: npc_image.texture = NPC_1_IMAGE
		1: npc_image.texture = NPC_2_IMAGE
		2: npc_image.texture = NPC_3_IMAGE


func _process(delta: float) -> void:
	pass

func progress_dialog() -> void:
	dialog_progress[selected_npc] += 1
	
	match dialog_progress[selected_npc]:
		0:
			question_label.text = dialog[selected_npc]["introduction"]
			

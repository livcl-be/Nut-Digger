extends Node2D

@onready var question_label: Label = $Question
@onready var npc_image: Sprite2D = $NPC

# Images of npc's
@export var NPC_AUGUST_IMAGE: Texture2D = null
@export var NPC_BILLIE_IMAGE: Texture2D = null
@export var NPC_FRANCIS_IMAGE: Texture2D = null

var selected_npc: int = 0
var got_ring: bool = false

var dialog_progress: int = 0

const dialog_options: Array[Variant] = ["Fireflies", "Who are you?", "Let's talk", "propose"]

const dialog: Array[Variant] = [
	{
		"name": "August",
		"introduction": "Oh okay, my name is August, uhm, It's been so long since I did this!... Ah! I like baking pies and a nice sweet tea in the morning!",
		"neutral message": "How's it going sweety?",
		"neutral answer": "Oooh alright…",
		"fireflies": ["Of course, here you go honey.", "Oh I already gave them to you, remember? It's okay sweety we all forget things sometimes."],
		"questions": ["What's your favourite dessert?", "Could you help me with my groceries Friday? I've been having a hard time getting them up here...", "What do you think is important in life?"],
		"answers": [["Tiramisu", "I don't like sweets", "Macarons"], ["I don't know yet","Of course!","No, sorry"], ["Enjoying the time I have", "Staying healthy", "Keeping loved ones safe"]],
		"correct_answers": [2, 1, 0],
		"proposal": ["Oh sweety… I think you got the wrong idea...", "Oh, euhm okay yeah let's do it!", "YES YES 1000x YES!"],
		"inheritance": 4000,
	},
]

func _ready() -> void:
	match selected_npc:
		0: npc_image.texture = NPC_AUGUST_IMAGE
		1: npc_image.texture = NPC_BILLIE_IMAGE
		2: npc_image.texture = NPC_FRANCIS_IMAGE

	_update_dialog()


func _process(delta: float) -> void:
	pass

func _update_dialog() -> void:
	match dialog_progress:
		0:
			question_label.text = dialog[selected_npc]["neutral message"]
	
			

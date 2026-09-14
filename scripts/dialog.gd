extends Node2D

@onready var question_label: Label = $UI/Question
@onready var npc_image: Sprite2D = $NPC

@onready var answer_label_1: Label = $UI/Answers/Labels/AnswerLabel1
@onready var answer_label_2: Label = $UI/Answers/Labels/AnswerLabel2
@onready var answer_label_3: Label = $UI/Answers/Labels/AnswerLabel3

@onready var answer_choise_1: TextureRect = $UI/Answers/Choises/AnswerChoise1
@onready var answer_choise_2: TextureRect = $UI/Answers/Choises/AnswerChoise2
@onready var answer_choise_3: TextureRect = $UI/Answers/Choises/AnswerChoise3

# Images of npc's
@export var NPC_AUGUST_IMAGE: Texture2D = null
@export var NPC_BILLIE_IMAGE: Texture2D = null
@export var NPC_FRANCIS_IMAGE: Texture2D = null

# Images of answer highlights
@export var ANSWER_HIGHLIGHTED: Texture2D = null
@export var ANSWER_NOT_HIGHLIGHTED: Texture2D = null

var selected_npc: int = 0
var selected_input: int = 0
var got_ring: bool = false

enum dialog_progress {INTRODUCTION, FIREFLIES, WHO, LETS, PROPOSE}
var current_progress: dialog_progress = dialog_progress.INTRODUCTION

var update_gui: bool = true

const dialog_options: Array[String] = ["Fireflies", "Who are you?", "Let's talk"]
const dialog_options_with_propose: Array[String] = ["Who are you?", "Let's talk", "propose"]

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

	


func _process(delta: float) -> void:
	handle_choises()
	
	if update_gui:
		_update_dialog()

func _update_dialog() -> void:
	update_gui = false
	
	match dialog_progress:
		0:
			show_question_dialog(dialog[selected_npc]["neutral message"])
			show_answer_dialog(dialog_options)
			
	
			
func show_question_dialog(question: String):
	question_label.text = question

func show_answer_dialog(answer: Array[String]):
	print_debug(answer)
	answer_label_1.text = "    " + answer[0]
	answer_label_2.text = "    " + answer[1]
	answer_label_3.text = "    " + answer[2]

func handle_choises():
	if Input.is_action_just_pressed("GB_up"):
		update_gui = true
		
		selected_input -= 1
		if selected_input < 0:
			selected_input = 2
		
		match selected_input:
			0:
				answer_choise_1.texture = ANSWER_HIGHLIGHTED
				answer_choise_2.texture = ANSWER_NOT_HIGHLIGHTED
			1:
				answer_choise_2.texture = ANSWER_HIGHLIGHTED
				answer_choise_3.texture = ANSWER_NOT_HIGHLIGHTED
			2:
				answer_choise_3.texture = ANSWER_HIGHLIGHTED
				answer_choise_1.texture = ANSWER_NOT_HIGHLIGHTED
			_: selected_input = 0

	if Input.is_action_just_pressed("GB_down"):
		update_gui = true
		
		selected_input += 1
		if selected_input > 2:
			selected_input = 0

		match selected_input:
			0:
				answer_choise_1.texture = ANSWER_HIGHLIGHTED
				answer_choise_3.texture = ANSWER_NOT_HIGHLIGHTED
			1:
				answer_choise_2.texture = ANSWER_HIGHLIGHTED
				answer_choise_1.texture = ANSWER_NOT_HIGHLIGHTED
			2:
				answer_choise_3.texture = ANSWER_HIGHLIGHTED
				answer_choise_2.texture = ANSWER_NOT_HIGHLIGHTED
			_: selected_input = 0

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
@export_group("Character images")
@export var NPC_AUGUST_IMAGE: Texture2D = null
@export var NPC_BILLIE_IMAGE: Texture2D = null
@export var NPC_FRANCIS_IMAGE: Texture2D = null
@export var NPC_SHOPKEEPER_IMAGE: Texture2D = null

# End scene
@export_group("End scenes")
@export var END_SCENE: PackedScene = null

# Images of answer highlights
@export_group("Dialog selected answer highlighting")
@export var ANSWER_HIGHLIGHTED: Texture2D = null
@export var ANSWER_NOT_HIGHLIGHTED: Texture2D = null

var selected_npc: int = 0
var selected_input: int = 0

enum shop_progress {NEUTRAL, BET, TIP, RING}
var current_shop_progress: shop_progress = shop_progress.NEUTRAL

enum progress {NEUTRAL, FIREFLIES, WHO, LETS, PROPOSE}
var current_progress: progress = progress.NEUTRAL
var current_question: int = 0
var asking_question: bool = false
var talked: Array[bool] = [false, false, false]
var npc_points: Array[int] = [0, 0, 0]

var update_gui: bool = true

const dialog_options: Array[String] = ["Fireflies", "Who are you?", "Let's talk"]
const dialog_options_with_propose: Array[String] = ["Who are you?", "Let's talk", "propose"]

const dialog: Array[Variant] = [
	{
		"name": "August",
		"introduction": "Oh okay, my name is August, uhm, It's been so long since I did this!... Ah! I like baking pies and a nice sweet tea in the morning!",
		"neutral message": "How's it going sweety?",
		"neutral answer": "Oooh alright...",
		"fireflies": ["Of course, here you go honey.", "Oh I already gave them to you, remember? It's okay sweety we all forget things sometimes."],
		"questions": ["What's your favourite dessert?", "Could you help me with my groceries Friday? I've been having a hard time getting them up here...", "What do you think is important in life?"],
		"answers": [["Tiramisu", "I don't like sweets", "Macarons"], ["I don't know yet","Of course!","No, sorry"], ["Enjoying the time I have", "Staying healthy", "Keeping loved ones safe"]],
		"correct_answers": [2, 1, 0],
		"incorrect_answers": [1, 2],
		"proposal": ["Oh sweety... I think you got the wrong idea...", "Oh, euhm okay yeah let's do it!", "YES YES 1000x YES!"],
		"inheritance": 4000,
	},

	{
		"name": "Billie",
		"introduction": "Name's Billie, been on this earth for 8 whole years. Used to love golfin', but can't no more cuz of my back.",
		"neutral message": "What do you want?",
		"neutral answer": "I see",
		"fireflies": ["Here take em', they're a hassle to take care of anyways...", "Don't come asking stupid questions now, Don't have 'em no more!"],
		"questions": ["How much money ya got?", "Why are you really here? Chatting us all up?", "What do you think is important in life?"],
		"answers": [["It's a secret", "I'm piss poor", "I prefer not to say"], ["I like old squirrels", "I'm looking for money","I want to marry"], ["Enjoying the time I have", "Staying healthy", "Keeping loved ones safe"]],
		"correct_answers": [1, 1, 1],
		"incorrect_answers": [0, 1],
		"proposal": ["I'm in no need of a dishonest partner.", "Sure, only if you'll play scrabble with me everyday...", "You want money, I want company, it's a deal!"],
		"inheritance": 11000,
	},

	{
		"name": "Francis",
		"introduction": "Alright... Hi, I'm Francis, I love nature and stuff... Oeh! And I'm always sniffing for some good deals on hiking gear!",
		"neutral message": "What's up partner?",
		"neutral answer": "I'll keep that in mind!",
		"fireflies": ["Coming right up! Don't let them fly away! ", "Erm didn't I give 'em to ya earlier? Or did I forget something again?"],
		"questions": ["Do you prefer the forest or the lake?", "What kinds of jokes are the best?", "What do you think is important in life?"],
		"answers": [["The forest","The lake","The indoors"], ["Knock knock jokes", "Puns", "Little Johnny jokes"], ["Enjoying the time I have", "Staying healthy", "Keeping loved ones safe"]],
		"correct_answers": [1, 1, 2],
		"incorrect_answers": [2],
		"proposal": ["Oh dear, uhm, how can I say this nicely...", "Jeez louise, okay let's do it!", "What a lovely surprise, of course!"],
		"inheritance": 7000,
	},

	{
		"name": "Shopkeeper",
		"introduction": "Oh no you're cut off buddy. No more bets until you've repaid your debt.",
		"neutral message": "What's up?",
		"neutral answer": "",
		"quest": "You know I heard about a golden ring in the dark forest, I'll give you 1k nuts for it, or you can use it to marry some rich idiot hahaha",
		"return_no_ring": "You get the ring yet brokie?",
		"ring": "Wow I didn't think you'd actually go get it",
		"inheritance": 1000,
	},
]

func _ready() -> void:
	selected_npc = Global.selected_npc
	talked = Global.talked
	npc_points = Global.npc_points
	current_question = Global.talk_progress[selected_npc]
	
	match selected_npc:
		0: npc_image.texture = NPC_AUGUST_IMAGE
		1: npc_image.texture = NPC_BILLIE_IMAGE
		2: npc_image.texture = NPC_FRANCIS_IMAGE
		3: npc_image.texture = NPC_SHOPKEEPER_IMAGE

	$Camera.make_current()
	
func _process(delta: float) -> void:
	_up_down_input()
	_enter_input()
	
	if update_gui:
		_update_dialog()
		Global.sound_effect_boop()

func _update_dialog() -> void:
	update_gui = false
	
	if selected_npc < 3:
		match current_progress:
			progress.NEUTRAL:
				show_question_dialog(dialog[selected_npc]["neutral message"])
				
				if Global.has_collected_ring():
					show_answer_dialog(dialog_options_with_propose)
				else:
					show_answer_dialog(dialog_options)
				
			progress.FIREFLIES:
				if Global.gave_fireflies[selected_npc]:
					show_question_dialog(dialog[selected_npc]["fireflies"][1])
				else:
					show_question_dialog(dialog[selected_npc]["fireflies"][0])
				
				show_answer_dialog(["Go to start", "Close dialog", ""])
			
			progress.WHO:
				show_question_dialog(dialog[selected_npc]["introduction"])
				show_answer_dialog(["Go to start", "Close dialog", ""])
			
			progress.LETS:
				if talked[selected_npc]: # Already talked to this npc
					show_question_dialog("I think that we have talked enough.")
					show_answer_dialog(["Go to start", "Close dialog", ""])
				elif !asking_question:
					show_question_dialog(dialog[selected_npc]["questions"][current_question])
					show_answer_dialog(dialog[selected_npc]["answers"][current_question])
				else:
					
					show_question_dialog(dialog[selected_npc]["neutral answer"])
					show_answer_dialog(["Go to start", "Close dialog", ""])
			
			progress.PROPOSE:
				if !talked[selected_npc]: # Did not talk to this npc
					show_question_dialog("Let's first talk a bit.")
					show_answer_dialog(["Okay", "", ""])
				elif npc_points[selected_npc] < 0:
					show_question_dialog(dialog[selected_npc]["proposal"][0])
					show_answer_dialog(["Go to start", "Close dialog", ""])
				elif npc_points[selected_npc] == 0:
					show_question_dialog(dialog[selected_npc]["proposal"][1])
					show_answer_dialog(["End game", "", ""])
				elif npc_points[selected_npc] > 0:
					show_question_dialog(dialog[selected_npc]["proposal"][2])
					show_answer_dialog(["End game", "", ""])
	else:
		match current_shop_progress:
			shop_progress.NEUTRAL:
				show_question_dialog(dialog[selected_npc]["neutral message"])

				if Global.has_collected_ring():
					show_answer_dialog(["I have the ring", "", ""])
				else:
					show_answer_dialog(["I want to bet.", "Money tips?", "Close dialog"])
					
			shop_progress.BET:
				Global.current_mission = Global.mission.DARK_FOREST
				show_question_dialog(dialog[selected_npc]["introduction"])
				show_answer_dialog(["Go to start", "Close dialog", ""])
				
			shop_progress.TIP:
				if !Global.asked_shopkeeper_moneytips:
					Global.asked_shopkeeper_moneytips = true
					show_question_dialog(dialog[selected_npc]["quest"])
				else:
					show_question_dialog(dialog[selected_npc]["return_no_ring"])
					
				show_answer_dialog(["Go to start", "Close dialog", ""])
			
			shop_progress.RING:
				show_question_dialog(dialog[selected_npc]["ring"])
				show_answer_dialog(["Bet ring", "Sell ring", ""])

func display_end_scene():
	Global.sound_effect_success()
	Global.goto_end_scene(END_SCENE)
			
func show_question_dialog(question: String):
	question_label.text = question

func show_answer_dialog(answer: Array[Variant]):
	answer_label_1.text = "    " + answer[0]
	answer_label_2.text = "    " + answer[1]
	answer_label_3.text = "    " + answer[2]

func _enter_input():
	if Input.is_action_just_pressed("GB_B"):
		update_gui = true

		if selected_npc < 3:
			match current_progress:
				progress.NEUTRAL: current_progress = (selected_input + 1 + (1 if Global.has_collected_ring() else 0)) as progress
				progress.FIREFLIES: # option 1: goto start; option 2: close
					if !Global.gave_fireflies[selected_npc]:
						Global.gave_fireflies[selected_npc] = true
						Global.append_fireflies()
					
					end_of_dialog_tree()
				progress.WHO: # option 1: goto start; option 2: close
					end_of_dialog_tree()
				progress.LETS:
					if talked[selected_npc]: # Already talked to this npc
						end_of_dialog_tree()
					elif !asking_question:
						asking_question = true
						if selected_input == dialog[selected_npc]["correct_answers"][current_question]:
							npc_points[selected_npc] += 1
						elif !(selected_npc == 2 and current_question == 1) and current_question != 2 and selected_input == dialog[selected_npc]["incorrect_answers"][current_question]:
							npc_points[selected_npc] -= 1
						
						current_question += 1
						Global.talk_progress[selected_npc] = current_question
						if current_question > 2:
							talked[selected_npc] = true
					else:
						asking_question = false
						end_of_dialog_tree()
						
							
				progress.PROPOSE:
					if !talked[selected_npc]:
						if selected_input == 0:
							current_progress = progress.LETS
					elif npc_points[selected_npc] < 0:
						end_of_dialog_tree()
					elif selected_input == 0:
						display_end_scene()
		else:
			match current_shop_progress:
				shop_progress.NEUTRAL:
					if Global.has_collected_ring() and selected_input == 0:
						current_shop_progress = shop_progress.RING
					elif Global.has_collected_ring():
						pass
					elif selected_input < 2 or Global.has_collected_ring():
						current_shop_progress = selected_input + 1 as shop_progress
					elif selected_input == 2 and !Global.has_collected_ring():
						close_dialog()
	
				shop_progress.BET: end_of_dialog_tree()
				shop_progress.TIP: end_of_dialog_tree()
				shop_progress.RING:
					match selected_input:
						0: display_end_scene()
						1:
							Global.sold_ring = true
							display_end_scene()

		selected_input = 0
		_update_highlighted_choise()

func end_of_dialog_tree():
	match selected_input:
		0:
			current_progress = progress.NEUTRAL
			current_shop_progress = shop_progress.NEUTRAL
		1: close_dialog()

func close_dialog():
	Global.selected_npc = selected_npc
	Global.talked = talked
	Global.npc_points = npc_points
	
	Global.goback_scene()


func _up_down_input():
	if Input.is_action_just_pressed("GB_up"):
		update_gui = true
		
		selected_input -= 1
		if selected_input < 0:
			selected_input = 2

		_update_highlighted_choise()

	if Input.is_action_just_pressed("GB_down"):
		update_gui = true
		
		selected_input += 1
		if selected_input > 2:
			selected_input = 0

		_update_highlighted_choise()

func _update_highlighted_choise():
	match selected_input:
		0:
			answer_choise_1.texture = ANSWER_HIGHLIGHTED
			answer_choise_3.texture = ANSWER_NOT_HIGHLIGHTED
			answer_choise_2.texture = ANSWER_NOT_HIGHLIGHTED
		1:
			answer_choise_2.texture = ANSWER_HIGHLIGHTED
			answer_choise_1.texture = ANSWER_NOT_HIGHLIGHTED
			answer_choise_3.texture = ANSWER_NOT_HIGHLIGHTED
		2:
			answer_choise_3.texture = ANSWER_HIGHLIGHTED
			answer_choise_2.texture = ANSWER_NOT_HIGHLIGHTED
			answer_choise_1.texture = ANSWER_NOT_HIGHLIGHTED
		_: selected_input = 0

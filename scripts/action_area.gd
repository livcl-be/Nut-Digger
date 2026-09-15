extends Area2D

### CONDITIONS ###
##################
@export_group("Conditional")
@export var on_key_press: bool = true

### HARDCODED DARK FOREST LOGIC ###
###################################
@export_group("Dark Forest")
@export var dark_forest_trigger: bool = false
@export var dark_forest_scene: PackedScene = null
@export var dark_forest_message_if_no_lamp: String = ""

### GO A SCENE BACK ###
#######################
@export_group("Go Back a Scene")
@export var go_back_a_scene: bool = false

### GO TO SCENE ###
###################
@export_group("Got to a Scene")
@export var go_to_scene: bool = false
@export var npc_index: int = 0
@export var scene: PackedScene = null

var inside_area: bool = false
var player_body: Node2D = null

### TEXT POPUP ###
##################
@export_group("Popup")
@export var enable_popup: bool = false
@export var message: String = ""
@export var popup: PackedScene = null

var popup_currently_active: bool = false
var player: Node = null

func _ready() -> void:
	# Reuse popup logic for hardcoded darkforest trigger
	if dark_forest_message_if_no_lamp != "":
		message = dark_forest_message_if_no_lamp
	
	# Get player for popup logic
	if get_parent().has_node("Player"):
		player = get_parent().get_node("Player")
	else:
		var root: Window = get_tree().root
		player = root.get_child(-1).get_node("Player")

func _process(delta: float) -> void:
	_process_input()

func _process_input() -> void:
	if on_key_press and inside_area and Input.is_action_just_pressed("GB_B"):
		_execute_logic()

func _execute_logic() -> void:
	# Scene management
	if go_back_a_scene:
		Global.goback_scene()
	elif go_to_scene and player_body:
		Global.selected_npc = npc_index
		Global.goto_scene(scene)

	# Popup logic
	var popup_conditional: bool = enable_popup or (dark_forest_trigger and !Global.has_collected_all_fireflies())
	if popup_conditional and !popup_currently_active:
		popup_currently_active = true
		player.show_popup(message, popup)
	elif popup_conditional and popup_currently_active:
		popup_currently_active = false
		player.hide_popup()
	
	# Hardcoded dark forest trigger
	if dark_forest_trigger and Global.has_collected_all_fireflies():
		Global.goto_scene(dark_forest_scene)
	
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		inside_area = true
		player_body = body
		
		# Execute logic when entering body if chosen
		if !on_key_press:
			_execute_logic()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		inside_area = false

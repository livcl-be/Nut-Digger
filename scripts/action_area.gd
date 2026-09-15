extends Area2D

### GO A SCENE BACK ###
#######################
@export var go_back_a_scene: bool = false

### GO TO SCENE ###
###################

@export var go_to_scene: bool = false
@export var npc_index: int = 0
@export var scene: PackedScene = null

var inside_area: bool = false
var player_body: Node2D = null

### TEXT POPUP ###
##################

@export var enable_popup: bool = false
@export var message: String = ""
@export var popup: PackedScene = null

var popup_currently_active: bool = false
var player: Node = null

func _ready() -> void:
	if get_parent().has_node("Player"):
		player = get_parent().get_node("Player")
	else:
		var root: Window = get_tree().root
		player = root.get_child(-1).get_node("Player")

func _process(delta: float) -> void:
	_process_input()

func _process_input() -> void:
	if Input.is_action_just_pressed("GB_B") and inside_area:
		if go_to_scene and player_body:
			Global.selected_npc = npc_index
			Global.goto_scene(scene)

		if enable_popup and !popup_currently_active:
			popup_currently_active = true
			player.show_popup(message, popup)
			
		elif enable_popup and popup_currently_active:
			popup_currently_active = false
			player.hide_popup()
		
		if go_back_a_scene:
			Global.goback_scene()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		inside_area = true
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		inside_area = false

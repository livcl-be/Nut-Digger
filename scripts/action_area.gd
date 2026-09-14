extends Area2D

### SCENE SWITCH ###
####################

@export var go_to_dialog: bool = false
@export var npc_index: int = 0
@export_global_file("*.tscn") var dialog: String = "res://scenes/dialog.tscn"

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
		if go_to_dialog and player_body:
			Global.selected_npc = npc_index
			Global.goto_scene(dialog)

		if enable_popup and !popup_currently_active:
			popup_currently_active = true
			player.show_popup(message, popup)
			
		elif enable_popup and popup_currently_active:
			popup_currently_active = false
			player.hide_popup()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		inside_area = true
		player_body = body

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		inside_area = false

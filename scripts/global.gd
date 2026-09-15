extends Node

var loaded_scene: Array[Node] = []
var loaded_scene_index: int = -1

var has_ring: bool = false
var collected_fireflies: int = 0

# Dialog non volatile variables
var asked_shopkeeper_moneytips: bool = false
var selected_npc: int = 0
var gave_fireflies: Array[bool] = [false, false, false]
var talked: Array[bool] = [false, false, false]
var npc_points: Array[int] = [0, 0, 0]

func append_fireflies() -> void:
	collected_fireflies += 1

func has_collected_all_fireflies() -> bool:
	return collected_fireflies > 2

func collected_ring() -> void:
	has_ring = true

func has_collected_ring() -> bool:
	return has_ring

func _ready():
	var root: Window = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	var main_scene: Node = root.get_child(-1)
	loaded_scene.append(main_scene)
	loaded_scene_index += 1

func goto_scene(scene: PackedScene):
	_deferred_goto_scene.call_deferred(scene)

func _deferred_goto_scene(scene: PackedScene):
	loaded_scene[loaded_scene_index].process_mode = ProcessMode.PROCESS_MODE_DISABLED

	# Instantiate the new scene.
	loaded_scene.append( scene.instantiate())
	loaded_scene_index += 1
	get_tree().root.add_child(loaded_scene[loaded_scene_index])
	get_tree().current_scene = loaded_scene[loaded_scene_index]
	_activate_player_camera(loaded_scene[loaded_scene_index])
	

func goback_scene():
	loaded_scene_index -= 1
	
	_activate_player_camera(loaded_scene[loaded_scene_index]) # Activate camera on previous scene
	loaded_scene[loaded_scene_index + 1].queue_free() # Delete most recently added scene
	loaded_scene.pop_back()
	loaded_scene[loaded_scene_index].process_mode = ProcessMode.PROCESS_MODE_ALWAYS # Enable process mode on previous scene

func _activate_player_camera(scene: Node):
	if scene.has_node("Player"):
		scene.get_node("Player").make_camera_active()

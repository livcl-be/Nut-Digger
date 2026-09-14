extends Node

var main_scene: Node = null
var loaded_scene: Node = null

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
	main_scene = root.get_child(-1)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path: String):
	main_scene.process_mode = ProcessMode.PROCESS_MODE_DISABLED

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instantiate the new scene.
	loaded_scene = s.instantiate()
	get_tree().root.add_child(loaded_scene)
	get_tree().current_scene = loaded_scene

func goback_scene():
	loaded_scene.queue_free()
	if main_scene.has_node("Player"):
		main_scene.get_node("Player").make_camera_active()
		
	main_scene.process_mode = ProcessMode.PROCESS_MODE_ALWAYS

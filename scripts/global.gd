extends Node

var loaded_scene: Array[Node] = []
var loaded_scene_index: int = -1
var disable_scene_switching: bool = false

var has_ring: bool = false
var collected_fireflies: int = 0

# Dialog non volatile variables
var asked_shopkeeper_moneytips: bool = false
var selected_npc: int = 0
var gave_fireflies: Array[bool] = [false, false, false]
var talked: Array[bool] = [false, false, false]
var npc_points: Array[int] = [0, 0, 0]

# Mission logic
const missions: Array[Variant] = [["Gamble"], ["Find Fireflies for Lamp"], ["Find Ring"], ["Marry", "Gamble Ring"]]
enum mission {GAMBLE, FIREFLIES, RING, MARRY_OR_GAMBLE}
var current_mission: mission = mission.GAMBLE

func append_fireflies() -> void:
	collected_fireflies += 1
	
	if has_collected_all_fireflies():
		current_mission = mission.RING

func has_collected_all_fireflies() -> bool:
	return collected_fireflies > 2

func collected_ring() -> void:
	has_ring = true
	current_mission = mission.MARRY_OR_GAMBLE

func has_collected_ring() -> bool:
	return has_ring

func _ready():
	var root: Window = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	var main_scene: Node = root.get_child(-1)
	loaded_scene.append(main_scene)
	loaded_scene_index += 1

func goto_scene(scene: PackedScene):
	if !disable_scene_switching:
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

func move_player_of_previous_scene(translation: Vector2):
	var scene: Node = loaded_scene[loaded_scene_index - 1]
	if scene.has_node("Player"):
		var player: CharacterBody2D = scene.get_node("Player")
		player.translate(translation)
		player.velocity = Vector2.ZERO

func give_player_of_previous_scene_velocity(velocity: Vector2):
	_give_player_velocity(velocity, loaded_scene_index - 1)

func transfer_velocity_from_previous_scene_to_current_scene():
	_give_player_velocity(_get_velocity(loaded_scene_index - 1), loaded_scene_index)

func _give_player_velocity(velocity: Vector2, scene_index: int):
	var scene: Node = loaded_scene[scene_index]
	if scene.has_node("Player"):
		var player: CharacterBody2D = scene.get_node("Player")
		player.velocity = velocity

func _get_velocity(scene_index: int) -> Vector2:
	var scene: Node = loaded_scene[scene_index]
	if scene.has_node("Player"):
		var player: CharacterBody2D = scene.get_node("Player")
		return player.velocity
	return Vector2.ZERO

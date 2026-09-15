extends CharacterBody2D
class_name Movement

### CAMERA ###
##############

@onready var camera_rig: Node2D = $CameraRig
@onready var camera: Camera2D = $CameraRig/PlayerCamera

const CAMERA_HORIZONTAL_OFFSET: float = 10
const CAMERA_VERTICAL_OFFSET: float = 5
const CAMERA_HORIZONTAL_CLIP: float = 20
const CAMERA_VERTICAL_CLIP: float = 10

@export var CAMERA_MOVED_UPWARDS: float = 0

### ANIMATION ###
#################

@onready var sprite: AnimatedSprite2D = $Sprite

const SPRITE_START_JUMPING_SPEED: float = 2.2
const SPRITE_IDLE_SPEED: float = 0.4

### MOVEMENT ###
################

# Moving horizontal
const MIN_SPEED: float = 4.453125
const MAX_SPEED: float = 153.75
const MAX_FALL_SPEED: float = 270.0
const MAX_FALL_SPEED_CAP: float = 240.0
const MIN_SLOW_DOWN_SPEED: float = 33.75

const WALK_ACCELERATION: float = 133.59375
const WALK_FRICTION: float = 500.8125

# Dash movement
const DASH_DURATION: float = 0.1
const DASH_TIMEOUT: float = 0.5
const DASH_VELOCITY: float = 400

# Moving vertical
const JUMP_SPEED: int = -240
const LONG_JUMP_GRAVITY: int = 450
const GRAVITY: int = 1100

const START_JUMPING_TIME: float = 0.5

### MISSION LABEL ###
#####################
@onready var mission_label: Label = $CameraRig/PlayerCamera/MissionControl/MissionLabel
const missions: Array[Variant] = [["Gamble"], ["Find Fireflies for Lamp", "Find Ring"], ["Marry", "Gamble Ring"]]
var current_mission: int = 0

### POPUP'S ###
###############
var popup_object: Node = null

### PRE INIT VARS ###
#####################
var random = RandomNumberGenerator.new()

@export var is_facing_left: bool = false
var walk_to_the_left: bool = false
var is_jumping: bool = false
var is_start_jumping: bool = false
var is_falling: bool = false
var is_dashing: bool = false

var input_axis: Vector2 = Vector2.ZERO
var speed_scale: float = 0.0

var dashed_during_jump: bool = false
var dash_cooldown: bool = false
var previous_dash_velocity: Vector2 = Vector2.ZERO

var min_speed: float = MIN_SPEED
var max_speed: float = MAX_SPEED
var acceleration: float = WALK_ACCELERATION
var deacceleration: float = WALK_FRICTION

func _ready() -> void:
	sprite.animation_looped.connect(_on_sprite_animation_finished)
	random.seed = 12345

	# Apply offset for home's
	camera_rig.position.y = -CAMERA_MOVED_UPWARDS
	
	_update_mission_label()

func _process(_delta):
	if !popup_object:
		process_input()
		process_animation()
		process_camera_rig(_delta)
	else:
		sprite.stop()
	
func _physics_process(delta):
	if !popup_object:
		process_jump(delta)
		process_walk(delta)
		process_dash(delta)
	
		move_and_slide()

func _update_mission_label() -> void:
	var text_builder: String = "Missions"
	for mission in missions[current_mission]:
		text_builder = text_builder + "\n> " + mission
	mission_label.text = text_builder
	
func next_mission() -> void:
	current_mission += 1
	_update_mission_label()

func _on_sprite_animation_finished() -> void:
	var animation_name: StringName = sprite.animation

	if sprite.sprite_frames.has_animation(animation_name):
		if animation_name == "start jump":
			is_start_jumping = false
			is_jumping = true
		elif animation_name == "jump" and is_falling:
			sprite.speed_scale = SPRITE_IDLE_SPEED * 20
			sprite.play("jump to flying")
		elif animation_name == "jump to flying" and is_falling:
			sprite.speed_scale = SPRITE_IDLE_SPEED
			sprite.play("flying")
		elif animation_name == "idle" or animation_name == "idle blink":
			if (randi() % 50) > 30:
				sprite.play("idle blink")
			else:
				sprite.play("idle")
		else:
			sprite.play(animation_name)
			
	else:
		sprite.play("idle")

func process_input():
	input_axis.x = Input.get_axis("GB_left", "GB_right")
	input_axis.y = - Input.get_action_strength("GB_up")

func process_jump(delta: float):
	if is_on_floor():
		var jump_pressed: bool = Input.is_action_pressed("GB_up")
		
		if not jump_pressed and is_start_jumping:
			is_start_jumping = false
			is_jumping = false
		elif jump_pressed and !is_start_jumping and !is_jumping:
			is_start_jumping = true
			is_jumping = false
		elif jump_pressed and !is_start_jumping and is_jumping:
			velocity.y = JUMP_SPEED

	else:
		var gravity: int = GRAVITY

		if Input.is_action_pressed("GB_up") and not is_falling:
			gravity = LONG_JUMP_GRAVITY
		else:
			is_start_jumping = false

		velocity.y = velocity.y + gravity * delta

		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED_CAP

	if velocity.y > 0:
		is_jumping = false
		is_falling = true
	elif is_on_floor() and is_falling:
		is_falling = false
		
		if input_axis.x == 0:
			velocity.x = 0
		
func process_walk(delta: float):
	if input_axis.x:
		if velocity.x:
			is_facing_left = input_axis.x < 0.0
			walk_to_the_left = velocity.x < 0.0
			
		min_speed = MIN_SPEED

		is_facing_left = input_axis.x < 0.0
		walk_to_the_left = velocity.x < 0.0
		if (is_facing_left and walk_to_the_left) or (!is_facing_left and !walk_to_the_left) or velocity.x == 0:
			# Walking in the same direction as the velocity
			acceleration = WALK_ACCELERATION
			var target_speed: float = input_axis.x * MAX_SPEED
			velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)
		else:
			# Walking opposite to the velocity, first get to zero velocity
			velocity.x = move_toward(velocity.x, 0.0, deacceleration * delta)


	elif is_on_floor() and velocity.x:
		if input_axis.y:
			min_speed = MIN_SLOW_DOWN_SPEED
		else:
			min_speed = MIN_SPEED

		if abs(velocity.x) < min_speed:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, deacceleration * delta)
			
	

	speed_scale = abs(velocity.x) / MAX_SPEED

func process_dash(delta: float):
	if Input.is_action_just_pressed("GB_A") and !is_dashing and !dash_cooldown and (is_on_floor() or !dashed_during_jump):
		previous_dash_velocity = velocity
		velocity.x = -DASH_VELOCITY if is_facing_left else DASH_VELOCITY
		is_dashing = true
		get_tree().create_timer(DASH_DURATION).timeout.connect(dash_done)

func dash_done():
	velocity = previous_dash_velocity
	is_dashing = false
	dash_cooldown = true
	get_tree().create_timer(DASH_TIMEOUT).timeout.connect(func(): dash_cooldown = false)

func process_animation():
	var animation_name: StringName = sprite.animation
	sprite.flip_h = !is_facing_left
	
	if velocity and animation_name != "jump to flying":
		sprite.speed_scale = max(0.8, speed_scale * 5.0)

	if is_start_jumping:
		sprite.speed_scale = SPRITE_START_JUMPING_SPEED
		sprite.play("start jump")
	elif is_dashing:
		sprite.play("flying")
	elif is_falling and animation_name != "jump" and animation_name != "jump to flying":
		sprite.play("flying")
	elif is_jumping:
		sprite.play("jump")
	elif (input_axis.x or velocity.x) and !is_falling:
		sprite.play("run")
	elif animation_name != "idle blink" and !is_falling:
		sprite.speed_scale = SPRITE_IDLE_SPEED
		sprite.play("idle")

func process_camera_rig(delta: float):
	camera_rig.position.x += input_axis.x * CAMERA_HORIZONTAL_OFFSET * delta * 7
	camera_rig.position.y += input_axis.y * CAMERA_VERTICAL_OFFSET * delta * 7
	
	# Clipping
	if CAMERA_HORIZONTAL_CLIP < abs(camera_rig.position.x):
		var dir = camera_rig.position.x / abs(camera_rig.position.x)
		camera_rig.position.x = dir * CAMERA_HORIZONTAL_CLIP

	if CAMERA_VERTICAL_CLIP < abs(camera_rig.position.y + CAMERA_MOVED_UPWARDS):
		var dir = camera_rig.position.y / abs(camera_rig.position.y)
		camera_rig.position.y = dir * CAMERA_VERTICAL_CLIP - CAMERA_MOVED_UPWARDS

func make_camera_active():
	camera.make_current()

func show_popup(message: String, popup: PackedScene):
	if !popup_object: # Avoid double popup's
		popup_object = popup.instantiate()
		
		if popup_object.has_node("Text"):
			popup_object.get_node("Text").text = message
		
		$CameraRig.add_child(popup_object)

func hide_popup():
	if popup_object:
		popup_object.free()
		print_debug(popup_object)
	
	popup_object = null

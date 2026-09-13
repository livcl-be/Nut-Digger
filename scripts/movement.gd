extends CharacterBody2D
class_name Movement

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

# Moving vertical
const JUMP_SPEED: int = -240
const LONG_JUMP_GRAVITY: int = 450
const GRAVITY: int = 1500

const START_JUMPING_TIME: float = 0.5

### PRE INIT VARS ###
#####################
var random = RandomNumberGenerator.new()

var is_facing_left: bool = false
var walk_to_the_left: bool = false
var is_jumping: bool = false
var is_start_jumping: bool = false
var is_falling: bool = false

var input_axis: Vector2 = Vector2.ZERO
var speed_scale = 0.0

var min_speed = MIN_SPEED
var max_speed = MAX_SPEED
var acceleration = WALK_ACCELERATION
var deacceleration = WALK_FRICTION

func _ready() -> void:
	sprite.animation_looped.connect(_on_sprite_animation_finished)
	random.seed = 12345

func _process(_delta):
	process_input()
	process_animation()
	
func _physics_process(delta):
	process_jump(delta)
	process_walk(delta)

	move_and_slide()

func _on_sprite_animation_finished() -> void:
	var animation_name: StringName = sprite.animation

	if sprite.sprite_frames.has_animation(animation_name):
		if animation_name == "start jump":
			is_start_jumping = false
			is_jumping = true
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
	input_axis.x = Input.get_axis("move_left", "move_right")
	input_axis.y = Input.get_axis("move_jump", "crouch")

func process_jump(delta: float):
	if is_on_floor():
		var jump_pressed: bool = Input.is_action_pressed("move_jump")
		
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

		if Input.is_action_pressed("move_jump") and not is_falling:
			gravity = LONG_JUMP_GRAVITY
		else:
			is_start_jumping = false

		velocity.y = velocity.y + gravity * delta

		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED_CAP

	if velocity.y > 0:
		is_jumping = false
		is_falling = true
	elif is_on_floor():
		is_falling = false
		
func process_walk(delta: float):
	if input_axis.x:
		if velocity.x:
			is_facing_left = input_axis.x < 0.0
			walk_to_the_left = velocity.x < 0.0
			
		if is_on_floor():
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

func process_animation():
	var animation_name: StringName = sprite.animation
	sprite.flip_h = !is_facing_left
	
	if velocity:
		sprite.speed_scale = max(1.4, speed_scale * 5.0)

	if is_start_jumping:
		sprite.speed_scale = SPRITE_START_JUMPING_SPEED
		sprite.play("start jump")
	elif is_jumping:
		sprite.play("jump")
	elif is_falling:
		sprite.play("flying")
	elif input_axis.x or velocity.x:
		sprite.play("run")
	elif animation_name != "idle blink":
		sprite.speed_scale = SPRITE_IDLE_SPEED
		sprite.play("idle")

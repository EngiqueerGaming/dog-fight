extends CharacterBody3D

@export var stats: CharacterStats

@onready var camera_mount: Node3D = $CameraMount

var display_name: String = "Character"
var max_health: int  = 100
var health: int = max_health
var alive: bool = true

var speed: float = 5
var sprint_speed: float = 8
var jump_velocity: float = 5
var max_jumps: int = 0
var current_jumps: int = 0
var air_acceleration: float = 0

@export var camera_sensitivity_x: float = 0.5
@export var camera_sensitivity_y: float = 0.5
const max_camera = 1.4
const min_camera = -1.4

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Determine selected character
	
	stats = preload("res://scripts/characters/TyphonStats.tres")
	
	display_name = stats.name
	max_health = stats.max_hp
	health = max_health
	speed = stats.walk_speed
	sprint_speed = stats.sprint_speed
	jump_velocity = stats.jump_velocity
	max_jumps = stats.jumps
	air_acceleration = stats.air_acceleration

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*camera_sensitivity_x))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y*camera_sensitivity_y))
		camera_mount.rotation[0] = clamp(deg_to_rad(camera_mount.rotation_degrees.x), min_camera, max_camera)

func _physics_process(delta: float) -> void:
	var just_jumped: bool = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and !is_on_floor() and current_jumps > 0:
		velocity.y = jump_velocity
		current_jumps -= 1
		just_jumped = true
	elif Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		just_jumped = true
	
	if is_on_floor():
		current_jumps = max_jumps
		just_jumped = false
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			if Input.is_action_pressed("sprint"):
				velocity.x = direction.x * sprint_speed
				velocity.z = direction.z * sprint_speed
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed*0.1)
			velocity.z = move_toward(velocity.z, 0, speed*0.1)
	else:
			if direction:
				if just_jumped:
					velocity.x = direction.x * sprint_speed
					velocity.z = direction.z * sprint_speed
				else:
					velocity.x = move_toward(velocity.x, direction.x * sprint_speed, sprint_speed*air_acceleration)
					velocity.z = move_toward(velocity.z, direction.z * sprint_speed, sprint_speed*air_acceleration)
	
	move_and_slide()

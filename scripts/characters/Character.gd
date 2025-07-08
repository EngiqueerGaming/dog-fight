extends CharacterBody3D

@export var stats: CharacterStats

@onready var camera_mount: Node3D = $CameraMount
@onready var attack_mount: Node3D = $AttackMount
const melee_hurtbox = preload("res://scenes/melee.tscn")

var display_name: String = "Jon Debug"
var max_health: int  = 100
var health: int = max_health
var alive: bool = true
@export var is_team_red: bool = true

var speed: float = 5
var sprint_speed: float = 8
var jump_velocity: float = 5
var max_jumps: int = 0
var current_jumps: int = 0
var air_acceleration: float = 0

var m1_attacks: Array[Array]
var m2_attacks: Array[Array]
var m1_attack_length: int
var m2_attack_length: int
var m1_attack: int = 0 
var m2_attack: int = 0
var attack_cooldown: float = 0

@export var camera_sensitivity_x: float = 0.5
@export var camera_sensitivity_y: float = 0.5
const max_camera = 1.4
const min_camera = -1.4

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Determine selected character
	
	if stats != null:
		display_name = stats.name
		max_health = stats.max_hp
		health = max_health
		speed = stats.walk_speed
		sprint_speed = stats.sprint_speed
		jump_velocity = stats.jump_velocity
		max_jumps = stats.jumps
		air_acceleration = stats.air_acceleration
		m1_attacks = stats.m1_attack_string
		m2_attacks = stats.m2_attack_string
		m1_attack_length = m1_attacks.size()
		m2_attack_length = m2_attacks.size()
	
	if is_team_red:
		set_collision_layer_value(2, true)
		set_collision_mask_value(3, true)
	else:
		set_collision_layer_value(3, true)
		set_collision_mask_value(2, true)

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

func _process(delta: float) -> void:
	attack_cooldown -= delta
	if Input.is_action_pressed("primary_attack") and attack_cooldown <= 0:
		m2_attack = 0
		if m1_attack < m1_attack_length:
			var hurtbox = melee_hurtbox.instantiate()
			hurtbox.x_scale = m1_attacks[m1_attack][0][0]
			hurtbox.y_scale = m1_attacks[m1_attack][0][1]
			hurtbox.z_scale = m1_attacks[m1_attack][0][2]
			hurtbox.rotate_z(m1_attacks[m1_attack][0][3])
			hurtbox.damage = m1_attacks[m1_attack][1]
			hurtbox.lifetime = m1_attacks[m1_attack][2][0]
			attack_cooldown = m1_attacks[m1_attack][2][1]
			attack_mount.add_child(hurtbox)
		else:
			m1_attack = 0
	if Input.is_action_just_released("primary_attack"):
		m1_attack = 0

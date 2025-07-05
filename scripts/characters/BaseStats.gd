class_name CharacterStats
extends Resource

@export var name: String = "Character"
@export var max_hp: int = 100
@export var walk_speed: float = 5
@export var sprint_speed: float = 8
@export var jumps: int = 1
@export var jump_velocity: float = 6
@export var air_acceleration: float = 0

@export var is_m1_ranged: bool = false
@export var is_m2_ranged: bool = false

# Attack should be formatted as vector 4 (x,y,z,rotation), (int)damage, vector 2(lifetime, delay)
# Delay of 0 = last attack
@export var m1_attack_string: Array[Array]
@export var m2_attack_string: Array[Array]

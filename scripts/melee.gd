extends Area3D

@onready var x_scale: float
@onready var y_scale: float
@onready var z_scale: float
var lifetime: float
var damage: int
var is_team_red: bool

var affected_entities: Array[CharacterBody3D]

@onready var hitbox: CollisionShape3D = $Hurtbox

func _ready():
	hitbox.scale[0] = x_scale
	hitbox.scale[1] = y_scale
	hitbox.scale[2] = z_scale
	
	if is_team_red:
		set_collision_mask_value(3, true)
	else:
		set_collision_mask_value(2, true)

func _process(delta: float) -> void:
	# Delete the hurtbox if the lifetime has expired
	lifetime -= delta
	if lifetime < 0:
		queue_free()
	# Get all hitboxes intersecting with me
	var entities: Array[Node3D] = get_overlapping_bodies()
	for e in entities:
		if e is CharacterBody3D and !affected_entities.has(e): # Check that this is a character, and that we have not delt damage yet
			e.health -= damage
			affected_entities.append(e)

extends CharacterBody3D
class_name Enemy

const SPEED = 5.0

## Distance to activate aggro
@export var aggro_range := 12.0
## Distance to start enemy attacks 
@export var attack_range := 1.5
## Max hitpoints of enemy
@export var max_hitpoints := 100
## Damage enemy does to player per hit
@export var damage := 10

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var player
var provoked := false
var hitpoints: int:
	set(value):
		hitpoints = value
		print('Enemy health: %d' % hitpoints)
		if hitpoints <= 0:
			queue_free()
		provoked = true


func _ready() -> void:
	player = get_tree().get_first_node_in_group('player')
	hitpoints = max_hitpoints
	

func _process(delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position

func _physics_process(delta: float) -> void:
	var next_position = navigation_agent_3d.get_next_path_position()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = global_position.direction_to(next_position)
	var distance = global_position.distance_to(player.global_position)
	provoked = distance <= aggro_range and provoked == false
	if provoked and distance <= attack_range:
		playback.travel("attack")
	if direction:
		face_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func face_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)

func attack() -> void:
	# Method is keyed into attack animation as a method track 
	print('Enemy attack')
	player.hitpoints -= damage

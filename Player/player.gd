extends CharacterBody3D

## Player jump height
@export var jump_height := 1.0
## Multiplier for quick player negative y displacement
@export var fall_multiplier := 2
## Genreal mouse acceleration 
@export var mouse_acceleration := 0.001
## Max player hitpoints
@export var max_hitpoints := 50
## Fov multiplier during aiming
@export var aim_multiplier := 0.7
@export var speed = 5.0




var mouse_motion = Vector2.ZERO
var hitpoints: int = max_hitpoints:
	set(value):
		if value < hitpoints:
			damage_animation_player.stop(false)
			damage_animation_player.play('TakeDamage')
		hitpoints = value
		if hitpoints <= 0:
			game_over_menu.game_over()
		print('Player healh: %s' % hitpoints)

@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation_player: AnimationPlayer = $DamageTexture/DamageAnimationPlayer
@onready var game_over_menu: Control = $GameOverMenu
@onready var ammo_handler: AmmoHandler = %AmmoHandler
@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var smooth_camera_fov := smooth_camera.fov
@onready var weapon_camera: Camera3D = %WeaponCamera
@onready var weapon_camera_fov = weapon_camera.fov

# Lerp fov transitions for smoother feel
func smooth_fov_transition(org_fov, new_fov, delta, multiplier=20.0) -> Variant:
	return lerp(org_fov, new_fov, delta * multiplier)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		smooth_camera.fov = smooth_fov_transition(smooth_camera.fov, smooth_camera_fov * aim_multiplier, delta)
		weapon_camera.fov = smooth_fov_transition(weapon_camera.fov, weapon_camera_fov * aim_multiplier, delta)
	else:
		smooth_camera.fov = smooth_fov_transition(smooth_camera.fov, smooth_camera_fov, delta)
		weapon_camera.fov = smooth_fov_transition(weapon_camera.fov, weapon_camera_fov, delta)

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * (fall_multiplier if velocity.y <= 0 else 1)

	# Handle jump.asdw
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * get_gravity().length() * 2.0)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# Multiply aim multiplier during aiming to make shots steadier 
		velocity.x = direction.x * speed * (aim_multiplier if Input.is_action_pressed("aim") else 1)
		velocity.z = direction.z * speed * (aim_multiplier if Input.is_action_pressed("aim") else 1)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	# Allow mouse motion only when mouse is captured
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Multiply aim multiplier to mouse_motion during aiming
		mouse_motion = -event.relative * mouse_acceleration * (aim_multiplier if Input.is_action_pressed("aim") else 1)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90, 90)
	mouse_motion = Vector2.ZERO

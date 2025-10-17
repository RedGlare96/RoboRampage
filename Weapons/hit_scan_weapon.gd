extends Node3D

## No of rounds per 1 unit
@export var fire_rate := 14.0
## Z displacement per shot
@export var recoil := 0.05
## Reference to Weapon Mesh object
@export var weapon_mesh: Node3D
## Multiper for speed of recovery to default position after recoil kickback
@export var recovery_multiplier := 10.0
## Damage per shot
@export var weapon_damage := 5
## Reference to muzzle flash particles object
@export var muzzle_flash: GPUParticles3D
## Reference to scene containing the corresponding impact effects
@export var sparks: PackedScene
## Is weapon automatic
@export var automatic: bool
@export var ammo_handler: AmmoHandler
@export var ammo_type : AmmoHandler.ammo_type

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_default_position = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Map to change input behaviour based on whether the weapon is automatic or not
var weapon_fire_map = {true: Input.is_action_pressed, false: Input.is_action_just_pressed}

func shoot() -> void:
	if ammo_handler.has_ammo(ammo_type):
		ammo_handler.use_ammo(ammo_type)
		muzzle_flash.restart()
		cooldown_timer.start(1 / fire_rate)
		weapon_mesh.position.z += recoil
		var collider = ray_cast_3d.get_collider()
		printt('Weapon fire', collider)
		if collider is Enemy:
			collider.hitpoints -= weapon_damage
		var spark = sparks.instantiate()
		add_child(spark)
		spark.global_position = ray_cast_3d.get_collision_point()

func _process(delta: float) -> void:
	if weapon_fire_map[automatic].call('fire'):
		if cooldown_timer.is_stopped():
			shoot()
	# Smoothly recover weapon from recoil position back to default
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_default_position, delta * recovery_multiplier)


		

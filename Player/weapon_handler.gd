extends Node3D

## Refrences to all possible weapon scenes
@export var weapons: Array[Node3D]

var current_weapon: Node3D = null

func _ready() -> void:
	if len(weapons) > 0:
		equip(weapons[0])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('weapon_1'):
		equip(weapons[0])
	if event.is_action_pressed('weapon_2'):
		equip(weapons[1])
	if event.is_action_pressed('weapon_next'):
		equip(weapons[wrapi(weapons.find(current_weapon) + 1, 0, weapons.size())])
	if event.is_action_pressed('weapon_previous'):
		equip(weapons[wrapi(weapons.find(current_weapon) - 1, 0, weapons.size())])

func equip(active_weapon: Node3D) -> void:
	# If being called at _ready(), disable all children
	# Children being looped over and not weapons array to account for child nodes that may not be in the array
	if not current_weapon:
		for weapon_ele in get_children():
			weapon_ele.visible = false
			weapon_ele.set_process(false)
			
	if active_weapon == current_weapon:
		return 
	elif current_weapon:
		current_weapon.visible = false
		current_weapon.set_process(false)
		
	active_weapon.visible = true
	active_weapon.set_process(true)
	current_weapon = active_weapon
	current_weapon.ammo_handler.update_label(current_weapon.ammo_type)

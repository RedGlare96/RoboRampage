extends Node
class_name AmmoHandler

@export var ammo_label: Label

enum ammo_type{
	STANDARD_CALIBER,
	SMALL_CALIBER
}

var ammo_storage := {ammo_type.STANDARD_CALIBER: 10, ammo_type.SMALL_CALIBER: 30}

func has_ammo(ammo_obj: ammo_type) -> bool:
	return ammo_storage[ammo_obj] > 0

func use_ammo(ammo_obj: ammo_type) -> void:
	if has_ammo(ammo_obj):
		ammo_storage[ammo_obj] -= 1
		update_label(ammo_obj)

func add_ammo(ammo_obj: ammo_type, amount: int) -> void:
	ammo_storage[ammo_obj] += amount
	update_label(ammo_obj)

func update_label(ammo_obj: ammo_type) -> void:
	ammo_label.text = '%s: %d' % [ammo_type.keys()[ammo_obj].replace('_', ' '), ammo_storage[ammo_obj]]

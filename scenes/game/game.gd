extends Node


@export_group("Scenes")
@export var MainMenu: PackedScene


func _ready() -> void:
	add_child(MainMenu.instantiate())

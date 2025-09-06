extends Node


@export_group("Scenes")
@export var PlayerScene: PackedScene


func _ready() -> void:
	SignalBus.add_player.connect(_on_add_player)


func _on_add_player(peer_id: int) -> void:
	var player_instance = PlayerScene.instantiate()
	player_instance.set_multiplayer_authority(peer_id)
	player_instance.name = str(peer_id)
	add_child(player_instance, true)

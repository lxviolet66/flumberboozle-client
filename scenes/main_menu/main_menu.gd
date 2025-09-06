extends Control


func _ready() -> void:
	SignalBus.game_started.connect(_on_game_started)
	SignalBus.menu_loaded.emit()


func _on_game_started() -> void:
	self.queue_free()

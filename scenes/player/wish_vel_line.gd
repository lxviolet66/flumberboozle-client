extends Vector2Line

@export_category("Nodes")
@export var Player: RigidBody3D
@export var Camera: Camera3D


func _ready() -> void:
	default_color = Color.PALE_VIOLET_RED
	width = 5


func _process(_delta: float) -> void:
	offset = Vector2(0.5, 1.5)
	
	vector = Vector2(
			Player.wish_vel.x,
			Player.wish_vel.z,
	).rotated(Camera.rotation.y) * 2
	
	queue_redraw()

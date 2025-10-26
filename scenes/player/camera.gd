extends Camera3D


var rotation_difference

@onready var Player: RigidBody3D = get_parent()


func _physics_process(_delta: float) -> void:
	rotation_difference = Player.fetch_rotation_difference()
	rotation_degrees -= Vector3(
			rotation_difference.y, rotation_difference.x, 0.0
	)
	
	position = Player.position


# TODO: https://www.youtube.com/watch?v=zfIuaRzNti4&pp=ygUMZ29kb3QgbmV0Zm94

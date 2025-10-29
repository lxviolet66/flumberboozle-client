extends Line2D

class_name Vector2Line

var offset: Vector2 = Vector2.ZERO
var vector: Vector2 = Vector2.ZERO

func _draw() -> void:
	var window_center: Vector2 = get_viewport_rect().size / 2
	clear_points()
	add_point(window_center * offset, 0)
	add_point(window_center * offset + vector, 1)

extends Label


@export var PortSlider: HSlider


func _on_port_slider_value_changed(new_value) -> void:
	self.text = str(int(new_value))

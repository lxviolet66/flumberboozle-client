extends CharacterBody3D


const ACCELERATION: float = 2.0
const DECELERATION: float = 0.1

@onready var CatastrophicallyImportantNode: Node3D = Global.find_node(
		"CatastrophicallyImportantNode"
)

var input_dir: Vector3
var mouse_input: Vector2


func _ready() -> void:
	# This causes lag, and should have a toggle
	# (Processing every input event can mean thousands every second on
	# fancy gaming mice with high polling rates)
	Input.set_use_accumulated_input(false)


func _physics_process(_delta: float) -> void:
	self.rotate_object_local(Vector3.LEFT, deg_to_rad(mouse_input.y))
	self.rotate_object_local(Vector3.DOWN, deg_to_rad(mouse_input.x))
	
	handle_input()

	var direction: Vector3 = transform.basis * input_dir.normalized()
	if direction:
		velocity = direction * ACCELERATION
	else:
		velocity = Vector3.ZERO

	move_and_slide()


func _process(delta: float) -> void:
	print(mouse_input)
	mouse_input = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
			#and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		mouse_input += event.screen_relative


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
			
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return


func handle_input() -> void:
	input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_down"):     input_dir.y -= 1
	if Input.is_action_pressed("move_up"):       input_dir.y += 1
	if Input.is_action_pressed("move_forward"):  input_dir.z -= 1
	if Input.is_action_pressed("move_backward"): input_dir.z += 1
	if Input.is_action_pressed("move_left"):     input_dir.x -= 1
	if Input.is_action_pressed("move_right"):    input_dir.x += 1

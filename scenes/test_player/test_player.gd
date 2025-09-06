extends CharacterBody3D


const SPEED: float = 10.0
const MAX_PITCH: float =  89.0
const MIN_PITCH: float = -89.0

var mouse_sensitivity: float = 100
var degrees_per_unit: float = 0.001

var motion: Vector2

var input_dir: Vector3
var mouse_input: Vector2

@export_group("Nodes")
@export var VeryImportantNode: Node3D# = Utils.find_node("VeryImportantNode")
@export var Synchronizer: MultiplayerSynchronizer# = Utils.find_node("Synchronizer")


func _ready() -> void:
	# Disabling this causes lag, and should have a toggle in future.
	# (Processing every input event can mean thousands every second on
	# fancy gaming mice with high polling rates)
	Input.set_use_accumulated_input(false)


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	handle_input()

	var direction: Vector3 = transform.basis * input_dir.normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector3.ZERO

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == MOUSE_BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			return
	
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			return
	
	if event is InputEventMouseMotion:
		handle_camera_movement(event)


func handle_camera_movement(event: InputEventMouseMotion) -> void:
	motion = event.screen_relative
	motion *= mouse_sensitivity
	motion *= degrees_per_unit
	
	apply_yaw(motion.y)
	apply_pitch(motion.x)


func apply_yaw(degrees: float) -> void:
	if not is_zero_approx(degrees):
		VeryImportantNode.rotate_object_local(
			Vector3.LEFT, deg_to_rad(degrees)
		)


func apply_pitch(degrees: float) -> void:
	if not is_zero_approx(degrees):
		self.rotate_object_local(Vector3.DOWN, deg_to_rad(degrees))


func handle_input() -> void:
	input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_down"):     input_dir.y -= 1
	if Input.is_action_pressed("move_up"):       input_dir.y += 1
	if Input.is_action_pressed("move_forward"):  input_dir.z -= 1
	if Input.is_action_pressed("move_backward"): input_dir.z += 1
	if Input.is_action_pressed("move_left"):     input_dir.x -= 1
	if Input.is_action_pressed("move_right"):    input_dir.x += 1

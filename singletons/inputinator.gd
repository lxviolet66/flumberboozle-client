extends Node
## Input gathering (and sometimes handling) singleton.
##
## Some things (e.g player movement) are handled in their own scripts, but
## all input gathering, sampling, averaging, doohickeying, etc is done here.


## We multiply mouse motion by this to prevent the issue of mouse sensitivity
## needing to be extremely low
const DEGREES_PER_UNIT: float = 0.01

## Direction the player is holding, or "wishes to go" in
static var wish_dir := Vector2.ZERO

## Accumulated mouse motion since the last time mouse motion was fetched
var rotation_difference := Vector2.ZERO

## Mouse sensitivity
var mouse_sensitivity: float = 10.0


## All we do in _ready() is disable accumulated input for more responsivity
func _ready() -> void:
	# 20 bucks says this line of code will break within a year (17/09/2025)
	Input.set_use_accumulated_input(false)


## Every physics tick, get the players wish direction
func _physics_process(_delta: float) -> void:
	wish_dir = Input.get_vector("move_left","move_right","move_forward","move_backward")


## :3
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		handle_keyboard_input(event)
	
	if event is InputEventMouseMotion:
		#if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		#	return
		handle_mouse_movement(event)


## Handle all keyboard input (no way really?)
func handle_keyboard_input(event: InputEventKey) -> void:
	if event.is_action_pressed("toggle_focus"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Get unscaled mouse motion unaffected by window resolution, and add it to
## the accumulated mouse motion
func handle_mouse_movement(event: InputEventMouseMotion) -> void:
	var motion = event.screen_relative
	motion *= mouse_sensitivity
	motion *= DEGREES_PER_UNIT
	rotation_difference += motion


## Fetch the accumulated mouse motion since last fetch, then reset it
func fetch_rotation_difference() -> Vector2:
	var return_value: Vector2 = rotation_difference
	rotation_difference = Vector2.ZERO
	return return_value


## wish_dir getter
func get_wish_dir() -> Vector2:
	return wish_dir

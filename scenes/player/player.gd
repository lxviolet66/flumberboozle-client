extends RigidBody3D

## TODO: write a documentation comment hehe


enum Movestates {
	#GROUNDED_WALK,
	#GROUNDED_SLIDE,
	#AIRBORNE_WALK,
	#AIRBORNE_SLIDE,
	GROUND,
	AIR,
	SLIDE,
	WALLRUN,
}

@export_category("Nodes")
@export var Camera: Camera3D
@export var GroundShapeCast: ShapeCast3D

const GROUND_ACCEL: float = 2.0
const GROUND_DRAG: float = 13.0
const GROUND_SNAP_LENGTH: float = 0.2

const AIR_ACCEL: float = 0.1
const AIR_DRAG: float = 0.1 # maybe just 0 air drag? that might feel nicer
const AIR_SNAP_LENGTH: float = 0.1

const SLIDE_ACCEL: float = 0.3
const SLIDE_DRAG: float = 2.0
const SLIDE_SNAP_LENGTH: float = GROUND_SNAP_LENGTH

const WALLRUN_ACCEL: float = 0.0
const WALLRUN_DRAG: float = 0.0
const WALLRUN_SNAP_LENGTH: float = AIR_SNAP_LENGTH

# this is not a "speed cap", just when to stop applying gravity.
# there will perhaps maybe in future be something that lets you instantly set
# your velocity to this (basically stolen from downshift from parkour legacy)
const TERMINAL_VELOCITY: float = 100.0

var ground_speed: float = 15.0
var air_speed: float = 15.0
var slide_speed: float = 15.0
var wallrun_speed: float = 20.0

var gravity_strength: float = 1.0
# This vector is the direction of gravity. This is a mutable variable.
# In other words: Freedom, imprisonment, it's all an illusion.
# Gravity, is a harness. I have harnessed the harness
var gravity_vector := Vector3(0, -1, 0).normalized() * gravity_strength

var current_movestate: Movestates = Movestates.GROUND


func _physics_process(_delta) -> void:
	pass


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Godot team please just add array/tuple unpacking to core already
	# this is just getting embarassing for you guys
	var x: Dictionary[String, float] = get_movestate_stats(current_movestate)
	var speed: float = x["speed"]
	var accel: float = x["accel"]
	var drag: float = x["drag"]
	var snap_length: float = x["snap_length"]
	
	var wish_dir: Vector2 = Inputinator.get_wish_dir()
	wish_dir = wish_dir.rotated(-Camera.rotation.y)
	
	var wish_vel := Vector3(wish_dir.x, 0, wish_dir.y) * speed
	
	if wish_vel.length() > 0:
		# maybe try experimenting with higher accel(decay) but less speed,
		# idk i just want this curve to be less "immediately fast but not at
		# max walk speed for 139 hours" and more "less immediate but still a
		# bit immediately fast and also at max walk speed pretty soon"
		# TL;DR: GROUVD MOVEMENT TOO FLOATY FIX IT!
		linear_velocity = Utils.exp_decay(
				linear_velocity,
				wish_vel,
				accel,
				state.step, # functionally identical to `delta` it seems
		)
	else:
		linear_velocity = Utils.exp_decay(
				linear_velocity,
				wish_vel,
				drag,
				state.step, # functionally identical to `delta` it seems
		)
	
	linear_velocity += gravity_vector
	
	# Snap horizontal velocity to 0 if it's small enough
	if (linear_velocity * Vector3(1, 0, 1)).length() < snap_length:
		linear_velocity *= Vector3(0, 1, 0)
	
	print(wish_dir, wish_vel, linear_velocity)


func get_movestate_stats(movestate) -> Dictionary[String, float]:
	match movestate:
		Movestates.GROUND:
			return {
				"speed": ground_speed,
				"accel": GROUND_ACCEL,
				"drag": GROUND_DRAG,
				"snap_length": GROUND_SNAP_LENGTH,
			}
		Movestates.AIR:
			return {
				"speed": air_speed,
				"accel": AIR_ACCEL,
				"drag": AIR_DRAG,
				"snap_length": AIR_SNAP_LENGTH,
			}
		Movestates.SLIDE:
			return {
				"speed": slide_speed,
				"accel": SLIDE_ACCEL,
				"drag": SLIDE_DRAG,
				"snap_length": SLIDE_SNAP_LENGTH,
			}
		Movestates.WALLRUN:
			return {
				"speed": wallrun_speed,
				"accel": WALLRUN_ACCEL,
				"drag": WALLRUN_DRAG,
				"snap_length": WALLRUN_SNAP_LENGTH,
			}
	
	# this should never happen, and exists just to shut up a godot warning
	# how about if it somehow does, somthing funny happens?
	return {
		"speed": 24727,
		"accel": 24727,
		"drag": 0,
	}

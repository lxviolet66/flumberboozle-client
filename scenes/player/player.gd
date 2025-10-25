extends RigidBody3D

## TODO: write a documentation comment hehe


enum Movestates {
	GROUND,
	AIR,
	SLIDE,
	WALLRUN,
}

@export_category("Physical Nodes")
@export var Camera: Camera3D
@export var GroundArea: Area3D

@export_category("UI Elements")
@export var WishJumpLabel: Label
@export var WishSlideLabel: Label
@export var WishDirLabel: Label
@export var WishVelLabel: Label
@export var PositionLabel: Label
@export var VelocityLabel: Label
@export var CoyoteTimeLabel: Label
@export var MovestateLabel: Label

const GROUND_SPEED: float = 15.0
const GROUND_ACCEL: float = 2.0
const GROUND_DRAG: float = 13.0
const GROUND_SNAP_LENGTH: float = 0.2

const AIR_SPEED: float = 15.0
const AIR_ACCEL: float = 0.3
const AIR_DRAG: float = 0.1 # maybe just 0 air drag? that might feel nicer
const AIR_SNAP_LENGTH: float = 0.1

const SLIDE_SPEED: float = 15.0
const SLIDE_ACCEL: float = 0.3
const SLIDE_DRAG: float = 2.0
const SLIDE_SNAP_LENGTH: float = GROUND_SNAP_LENGTH

const WALLRUN_SPEED: float = 20.0
const WALLRUN_ACCEL: float = 0.0
const WALLRUN_DRAG: float = 0.0
const WALLRUN_SNAP_LENGTH: float = AIR_SNAP_LENGTH

const JUMP_POWER: float = 1.5
const JUMP_BOOST_DECREMENT: float = JUMP_POWER/5

const MAX_COYOTE_TIME: float = 100

# this is not a "speed cap", just when to stop applying gravity.
# there will perhaps maybe in future be something that lets you instantly set
# your velocity to this (basically stolen from downshift from parkour legacy)
const TERMINAL_VELOCITY: float = 100.0


var gravity_strength: float = 10.0
# This vector is the direction of gravity. This is a mutable variable.
# In other words: Freedom, imprisonment, it's all an illusion.
# Gravity, is a harness. I have harnessed the harness
var gravity_vector := Vector3(0, -1, 0).normalized() * gravity_strength

# remember to add to this if the player "gains" any physics bodies
var our_physics_body_ids: Array[int] = []

var movestate: Movestates = Movestates.AIR

var coyote_time: float = 0
var jump_boost: float = 0
var jumping: bool = false

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("Player PhysicsBody3Ds"):
		our_physics_body_ids.append(node.get_instance_id())


func _physics_process(_delta) -> void:
	pass


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var things_touching_legs: Array = GroundArea.get_overlapping_bodies()
	movestate = determine_movestate(things_touching_legs)

	# Godot team please just add array/tuple unpacking to core already
	# this is just getting embarassing for you guys
	var __: Dictionary[String,float] = get_movestate_stats(movestate)
	var speed: float = __["speed"]
	var accel: float = __["accel"]
	var drag: float = __["drag"]
	var snap_length: float = __["snap_length"]
	
	var wish_jump: bool = Inputinator.get_wish_jump()
	var wish_slide: bool = Inputinator.get_wish_slide()
	var wish_dir: Vector2 = Inputinator.get_wish_dir()
	var wish_vel := wish_dir * speed
	var rotated_wish_dir : Vector2 = wish_dir.rotated(-Camera.rotation.y)
	var rotated_wish_vel : Vector2 = wish_vel.rotated(-Camera.rotation.y)
	
	if movestate == Movestates.GROUND:
		coyote_time = MAX_COYOTE_TIME
	
	if wish_jump:
		if coyote_time > 0:
			# Jump
			jump_boost = JUMP_POWER
			coyote_time = 0
		# Maintain jump
		if jump_boost > 0:
			linear_velocity.y += jump_boost
	else:
		jump_boost = 0
	jump_boost -= JUMP_BOOST_DECREMENT
	
	# FIXME: doing it like this is MID!!! the drag should be applied no matter
	# what, but rn it applies drag if wish_vel is (0, 0) and otherwise
	# it applies acceleration it should do both!!! wtf was i cooking!!!
	var decay: float = accel if wish_vel.length() > 0 else drag
	linear_velocity = Utils.exp_decay(
			linear_velocity,
			Vector3(rotated_wish_vel.x, 0, rotated_wish_vel.y),
			decay,
			state.step, # functionally identical to `delta`
	)
	
	linear_velocity += gravity_vector * state.step
	
	# Snap horizontal velocity to 0 if it's small enough
	if (linear_velocity * Vector3(1, 0, 1)).length() < snap_length:
		linear_velocity *= Vector3(0, 1, 0)
		
	update_debug_information(
			wish_jump,
			wish_slide,
			wish_dir,
			wish_vel,
			position,
			linear_velocity,
			coyote_time,
			movestate,
	)


func determine_movestate(things_touching_legs: Array[Node3D]) -> Movestates:
	for i in things_touching_legs:
		if i.get_instance_id() in our_physics_body_ids:
			things_touching_legs.erase(i)
	
	if (
			len(things_touching_legs) > 0
			and movestate in [Movestates.AIR, Movestates.WALLRUN]
	):
		return Movestates.GROUND

		
	elif (
			len(things_touching_legs) == 0
			and movestate in [Movestates.GROUND, Movestates.SLIDE]
	):
		return Movestates.AIR
	
	else:
		# Something has gone calamitously wrong (FUCK), and the player has no
		# valid movestate (or at the very least, we just couldn't find it).
		# We just return the air movestate, because something is better than
		# nothing, although perhaps in time a "Schrodinger's Movestate" could
		# be implemented.
		return Movestates.AIR

func update_debug_information(
	given_wish_jump: bool,
	given_wish_slide: bool,
	given_wish_dir: Vector2,
	given_wish_vel: Vector2,
	given_position: Vector3,
	given_velocity: Vector3,
	given_coyote_time: float,
	given_state: Movestates,
) -> void:
	WishJumpLabel.text = "%s" % given_wish_jump
	WishSlideLabel.text = "%s" % given_wish_slide
	WishDirLabel.text = "%.3+f / %.3+f" % [given_wish_dir.x, given_wish_dir.y]
	WishVelLabel.text = "%7.3-+f / %7.3-+f" % [given_wish_vel.x, given_wish_vel.y]
	PositionLabel.text = "%.3-+f / %.3-+f / %.3-+f" \
			% [given_position.x, given_position.y, given_position.z]
	VelocityLabel.text = "%8.3-+f / %8.3-+f / %8.3-+f / Length: %.3f" \
			% [given_velocity.x, given_velocity.y,
			   given_velocity.z, given_velocity.length()]
	CoyoteTimeLabel.text = "%.3f" % given_coyote_time
	MovestateLabel.text = "%s" % given_state


func get_movestate_stats(given_movestate) -> Dictionary[String, float]:
	match given_movestate:
		Movestates.GROUND:
			return {
				"speed": GROUND_SPEED,
				"accel": GROUND_ACCEL,
				"drag": GROUND_DRAG,
				"snap_length": GROUND_SNAP_LENGTH,
			}
		Movestates.AIR:
			return {
				"speed": AIR_SPEED,
				"accel": AIR_ACCEL,
				"drag": AIR_DRAG,
				"snap_length": AIR_SNAP_LENGTH,
			}
		Movestates.SLIDE:
			return {
				"speed": SLIDE_SPEED,
				"accel": SLIDE_ACCEL,
				"drag": SLIDE_DRAG,
				"snap_length": SLIDE_SNAP_LENGTH,
			}
		Movestates.WALLRUN:
			return {
				"speed": WALLRUN_SPEED,
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

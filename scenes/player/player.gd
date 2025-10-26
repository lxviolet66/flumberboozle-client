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
@export var HorizontalVelocityLabel: Label
@export var VerticalVelocityLabel: Label
@export var CoyoteTimeLabel: Label
@export var MovestateLabel: Label

@export_category("Curves")
@export var strafe_curve: Curve

# NOTICE: maybe for snap lengths, define them programmatically as the
# resulting velocity from moving in the current state

const GROUND_SPEED: float = 50.0
const GROUND_ACCEL: float = 2.0
const GROUND_DRAG: float = 13.0
const GROUND_SNAP_LENGTH: float = 0.2

const AIR_SPEED: float = 9.0
const AIR_ACCEL: float = 1.0
const AIR_DRAG: float = 0.0
const AIR_SNAP_LENGTH: float = 0.05

const SLIDE_SPEED: float = 15.0
const SLIDE_ACCEL: float = 0.3
const SLIDE_DRAG: float = 2.0
const SLIDE_SNAP_LENGTH: float = GROUND_SNAP_LENGTH

const WALLRUN_SPEED: float = 20.0
const WALLRUN_ACCEL: float = 0.0
const WALLRUN_DRAG: float = 0.0
const WALLRUN_SNAP_LENGTH: float = AIR_SNAP_LENGTH

const JUMP_POWER: float = 1.5
const JUMP_BOOST_DECREMENT: float = JUMP_POWER / 5

const MAX_COYOTE_TIME: float = 100

## VE REQUIRE ZIS VARIABLE TO MULTIPLY DAS [member rotation_difference] BY
## SUCH ZAT ZE MOTION APPLIED TO DAS PLAYER CAMERA IS LOWER, BUT ZE NUMERAL OF
## "MOUSE_SENSITIVITY" SHALL REMAIN AT A REASONABLE QUANTITY
const DEGREES_PER_UNIT: float = 0.01

# this is not a "speed cap", just when to stop applying gravity.
# there will perhaps maybe in future be something that lets you instantly set
# your Y velocity to this (basically stolen from parkour legacy downshift)
# ok maybe not EXACTLY this value but a similarly high value
const TERMINAL_VELOCITY: float = 100.0

## ZIS VARIABLE CONTAINS DAS VECTOR VHICH ZE PLAYER VISHES TO TRAVEL IN
## FOR INSTANCE, IF ZE PLAYER HOLDS FORWARD ZEN ZE VARIABLE SHALL HOLD ZE
## VALUE (0, -1)
## [br][br]
## IT IS OF MOST IMPORTANCE YOU KEEP IN MIND ZAT ZE VECTOR IS OF LENGTH 1
var wish_dir := Vector2.ZERO
## ZIS VARIABLE CONTAINS EIN BOOLEAN VALUE VHICH TELLS US IF ZE PLAYER VISHES
## TO JUMP
var wish_jump: bool = false
## ZIS VARIABLE CONTAINS EIN BOOLEAN VALUE VHICH TELLS US IF ZE PLAYER VISHES
## TO JUMP
var wish_slide: bool = false

## ZIS VARIABLE CONTAINS DAS "ACCUMULATED MOUSE MOTION" SINCE ZE PREVIOUS
## VETCHING OF DAS "ACCUMULATED MOUSE MOTION", FIRST MULTIPLIED BY
## [constant DEGREES_PER_UNIT] AND ZEN MULTIPLIED BY
## [member mouse_sensitivity]
var rotation_difference := Vector2.ZERO

## ZIS VARIABLE CONTAINS DAS USER SELECTED "MOUSE SENSITIVITY"
var mouse_sensitivity: float = 10.0

var gravity_strength: float = 10.0

## ZIS VECTOR IS ZE DIRECTION OF GRAVITY. ZIS IS EIN MUTABLE VARIABLE
## IN OTHER WORDS: FREEDOM, IMPRISONMENT, ETC, ALL ILLUSIONS
## ZE GRAVITY, IS EIN HARNESS. I HAVE HARNESSED ZE HARNESS
var gravity_vector := Vector3(0, -1, 0).normalized() * gravity_strength

## ZIS VARIABLE CONTAINS ZE IDS OF ALL "PHYSIC BODY" ZAT BELONG TO ZE PLAYER.
##[BR][BR]
## WE IGNORE ALL OF ZE "PHYSIC BODY" IN ZIS ARRAY VHEN VE CHECK FOR COLISSIONS
var our_physics_body_ids: Array[int] = []

var movestate: Movestates = Movestates.AIR

var coyote_time: float = 0
var jump_boost: float = 0
var jumping: bool = false

func _ready() -> void:
	# 20 bucks says this line of code will break within a year (17/09/2025)
	Input.set_use_accumulated_input(false)
	
	for node in get_tree().get_nodes_in_group("Player PhysicsBody3Ds"):
		our_physics_body_ids.append(node.get_instance_id())


func _physics_process(_delta) -> void:
	pass # :3


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		handle_keyboard_input(event)
	
	if (
			event is InputEventMouseMotion
			and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	):
		handle_mouse_movement(event)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var things_touching_legs: Array = GroundArea.get_overlapping_bodies()
	movestate = determine_movestate(things_touching_legs)

	# Godot team please just add array/tuple unpacking to core already
	# this is just getting embarassing for you guys
	var __: Dictionary[String,float] = get_movestate_stats(movestate)
	var move_speed: float = __["speed"]
	var move_accel: float = __["accel"]
	var move_drag: float = __["drag"]
	var snap_length: float = __["snap_length"]
	
	var wish_vel: Vector2 = wish_dir.rotated(-Camera.rotation.y) * move_speed
	var horizontal_velocity = Vector2(linear_velocity.x, linear_velocity.z)
	#var wish_vel: Vector2 = (
			#wish_dir * horizontal_velocity \
			#if horizontal_velocity.length() > move_speed
			#else wish_dir * move_speed
	#)
	
	## Angle between [member linear_velocity] and [member wish_vel]
	var strafe_angle: float = abs(rad_to_deg(wish_vel.angle_to(
			horizontal_velocity)))
	
	var strafe_multiplier: float = strafe_curve.sample(strafe_angle)
	print("%.3f %.3f" % [strafe_angle, strafe_multiplier])
	
	wish_vel *= strafe_multiplier
	
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
	linear_velocity = Utils.exp_decay(
			linear_velocity,
			Vector3(wish_vel.x, linear_velocity.y, wish_vel.y),
			move_accel,
			state.step, # functionally identical to `delta`
	)
	linear_velocity = Utils.exp_decay(
			linear_velocity,
			Vector3(0, 0, 0),
			move_drag,
			state.step, # functionally identical to `delta`
	)
	
	# maybe this should only be applied if the player isn't on the ground;
	# having the player rconstantly being pushed into the ground might not
	# be the best (but also at the same time kinda is good for physics e.g
	# you would probably want to be pushing to the platform you're standing on
	# if that platform is a physics object)
	if linear_velocity.y < TERMINAL_VELOCITY:
		linear_velocity += gravity_vector * state.step
	
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


## We Calleth Uponeth this Functionalitye at everye just opportunity with which
## we possesse an [InputEventKey], as provided by thine
## [method _unhandled_input].
## [br][br]
## Now Withholding thine [InputEventKey], we Operate Uponeth it.
## Fore instance, if Thoust Playere Inputeth thine "Space Bar", thine
## [member wish_jump] Property shall be Modified into Truthiness with Haste,
## Lest Thoust Worms experience thy Horror known as "Inputeth Delayeth"!
func handle_keyboard_input(event: InputEventKey) -> void:
	if event.is_action_pressed("toggle_focus"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	wish_dir = Input.get_vector(
			"move_left", "move_right",
			"move_forward", "move_backward"
	)
	
	# "Don't Repeat Yourself" is advice for cowards
	if event.is_action_pressed("jump"):
		wish_jump = true
	elif event.is_action_released("jump"):
		wish_jump = false
		
	if event.is_action_pressed("slide"):
		wish_slide = true
	elif event.is_action_released("slide"):
		wish_slide = false


## WE CALL ZIS FUNCTION VHENEVER VE RECEIVE EIN "INPUTEVENTMOUSEMOTION" DURING
## ZE PROCESSING OF "UNHANDLED INPUT"
func handle_mouse_movement(event: InputEventMouseMotion) -> void:
	## ZIS VARIABLE CONTAINS DAS UNSCALED POINTING DEVICE MOTION RELATIVE TO
	## DAS PREVIOUS POSITION IN ZE COORDINATE SYSTEM OF ZE SCREEN
	var motion = event.screen_relative
	rotation_difference += motion * mouse_sensitivity * DEGREES_PER_UNIT


## ZIS FUNCTION GRABS DAS "ROTATION DIFFERENCE" SINCE ZE LAST FRAME, DAS
## "ROTATION DIFFERENCE" IS DEFINED AS ZE AMOUNT ZE POINTING DEVICE HAS
## ROTATED SINCE ZE PREVIOUS TIME ZIS FUNCTION HAS RAN
## [br][br]
## IT IS OF MOST IMPORTANCE YOU KEEP IN MIND ZAT DAS "ROTATION DIFFERENCE" IS
## MULITPLIED TO INCREASE IT TO THE SPECIFIED SENSITIVITY, THIS IS DONE IN A
## DIFFERENT FUNCTION
func fetch_rotation_difference() -> Vector2:
	## ZIS IS EIN STUPID VARIABLE ZAT I VISH VAS NOT NECESSARY, ZE REASON
	## ZAT VE NEED IT IS IN ORDER TO FACILITATE ZE SETTING OF DAS VARIABLE TO
	## ZERO, WHILE ALSO RETURNING ZE VALUE BEFORE IT IS SET TO ZERO
	var stupid_fucking_variable: Vector2 = rotation_difference
	rotation_difference = Vector2.ZERO
	return stupid_fucking_variable
	

func determine_movestate(things_touching_legs: Array[Node3D]) -> Movestates:
	for i in things_touching_legs:
		if i.get_instance_id() in our_physics_body_ids:
			things_touching_legs.erase(i)
	
	if len(things_touching_legs) > 0:
		return Movestates.GROUND

		
	elif len(things_touching_legs) == 0:
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
	HorizontalVelocityLabel.text = "%.3f" \
			% Vector2(given_velocity.x, given_velocity.z).length()
	VerticalVelocityLabel.text = "%.3f" % given_velocity.y
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

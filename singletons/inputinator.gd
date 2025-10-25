extends Node

# TODO: this is actually kinda shit, put all the input code inside player.gd

## ZIS IS DAS "INPUTINATOR 6000"
##
## IT RECEIVES EIN INPUT AND DAS INPUT GETS INATORED


## VE REQUIRE ZIS VARIABLE TO MULTIPLY DAS [member rotation_difference] BY
## SUCH ZAT ZE MOTION APPLIED TO DAS PLAYER CAMERA IS LOWER, BUT ZE NUMERAL OF
## "MOUSE_SENSITIVITY" SHALL REMAIN AT A REASONABLE QUANTITY
const DEGREES_PER_UNIT: float = 0.01

## ZIS VARIABLE CONTAINS DAS VECTOR VHICH ZE PLAYER VISHES TO TRAVEL IN
## FOR INSTANCE, IF ZE PLAYER HOLDS FORWARD ZEN ZE VARIABLE SHALL HOLD ZE
## VALUE (0, -1)
## [br][br]
## IT IS OF MOST IMPORTANCE YOU KEEP IN MIND ZAT ZE VECTOR IS OF LENGTH 1
static var wish_dir := Vector2.ZERO
## ZIS VARIABLE CONTAINS EIN BOOLEAN VALUE VHICH TELLS US IF ZE PLAYER VISHES
## TO JUMP
static var wish_jump: bool = false
## ZIS VARIABLE CONTAINS EIN BOOLEAN VALUE VHICH TELLS US IF ZE PLAYER VISHES
## TO JUMP
static var wish_slide: bool = false

## ZIS VARIABLE CONTAINS DAS "ACCUMULATED MOUSE MOTION" SINCE ZE PREVIOUS
## VETCHING OF DAS "ACCUMULATED MOUSE MOTION", FIRST MULTIPLIED BY
## [constant DEGREES_PER_UNIT] AND ZEN MULTIPLIED BY
## [member mouse_sensitivity]
var rotation_difference := Vector2.ZERO

## ZIS VARIABLE CONTAINS DAS USER SELECTED "MOUSE SENSITIVITY"
var mouse_sensitivity: float = 10.0


func _ready() -> void:
	# 20 bucks says this line of code will break within a year (17/09/2025)
	Input.set_use_accumulated_input(false)


func _physics_process(_delta: float) -> void:
	wish_dir = Input.get_vector(
			"move_left", "move_right",
			"move_forward", "move_backward"
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		handle_keyboard_input(event)
	
	if event is InputEventMouseMotion:
		#if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		#	return
		handle_mouse_movement(event)


## We Calleth Uponeth this Functionalitye at everye just opportunity with which
## we possesse an [InputEventKey], as provided by thine [method _unhandled_input].
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
	
	if event.is_action_pressed("jump"):
		wish_jump = true
	else:
		wish_jump = false
		
	if event.is_action_pressed("slide"):
		wish_slide = true
	else:
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
## DIFFERENT FUNCTION AND ZIS IMPORTANT INFORMATION SHOULD PROBABLY BE PRESENT
## ZERE TOO
## [br][br]
## P.S I HAVE ADDED IT TO ZE FUNCTION OF VICH IT BELONGS :3
func fetch_rotation_difference() -> Vector2:
	## ZIS IS EIN STUPID VARIABLE ZAT I VISH VAS NOT NECESSARY, ZE REASON
	## ZAT VE NEED IT IS IN ORDER TO FACILITATE ZE SETTING OF DAS VARIABLE TO
	## ZERO, WHILE ALSO RETURNING ZE VALUE BEFORE IT IS SET TO ZERO
	var return_value: Vector2 = rotation_difference
	rotation_difference = Vector2.ZERO
	return return_value


## ZIS IS DAS "GETTER" FOR DAS "WISH_DIR"
func get_wish_dir() -> Vector2:
	return wish_dir
	
	
## ZIS IS DAS "GETTER" FOR DAS "WISH_JUMP"
func get_wish_jump() -> bool:
	return wish_jump


## ZIS IS DAS "GETTER" FOR DAS "WISH_SLIDE"
func get_wish_slide() -> bool:
	return wish_slide

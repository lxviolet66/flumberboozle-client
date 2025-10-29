extends Node


## Finds the first node in the node tree with a name that matches `pattern`.
## Uses `String.match()` behind the scenes, so you can use the following
## to do pattern matching:
## "*" matches zero or more of any characters
## (e.g *3D would match Sprite3D or Camera3D)
## "?" matches exactly one of any character
## (e.g ?_pos would match x_pos or y_pos but not global_pos)
func find_node(pattern: String) -> Node:
	return get_tree().get_root().find_child(pattern, true, false)


## From the talk "Lerp smoothing is broken" by Freya Holmér: 
## [url]https://www.youtube.com/watch?v=LSNQuFEDOyQ[/url]
## [br][br]
## Usage:
## [br][br]
## [member a] and [member b] are the start and end points respectively.
## [br]
## [member decay] is the exponential decay constant, the useful range for this is
## approx 1 to 25 (slow to fast)
## [br]
## [member delta] is the time elapsed since last frame (shocker)
## [br][br]
## Example usage:
## [codeblock]
## current_position = Utils.exp_decay(
##			current_position,
##			target_position,
##			ACCELERATION,
##			delta,
## )
## [/codeblock]
func exp_decay(a: Variant, b: Variant, decay: float, delta: float):
	return b + (a - b) * exp(-decay * delta)


## Takes in a [Vector2] or [Vector3] and changes the length to the
## [member length] parameter.
## [br][br]
## This is the same as just doing [code]v = (v / v.length() ) * l[/code], but
## calling this function when we want to change the length of a vector makes
## the intention of the code clearer
func set_length(vector: Variant, length) -> Variant:
	return (vector.normalized()) * length


## You can't use [code]pass[/code] in ternary expressions, but you can call a
## function that just does nothing :3
## This is a massive hack, and I kinda hate it, but not as much as I love the
## ternary operator
func nop() -> void:
	pass

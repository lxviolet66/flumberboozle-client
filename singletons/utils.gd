extends Node


## Finds the first node in the node tree with a name that matches `pattern`
## Uses `String.match()` behind the scenes, so you have the followin
## "*" matches zero or more characters (e.g *3D matches Sprite3D, Camera3D)
## "?" matches any character (e.g ?_pos matches x_pos and y_pos)
func find_node(pattern: String) -> Node:
	return get_tree().get_root().find_child(pattern, true, false)


## from the talk "Lerp smoothing is broken" by Freya Holmér
## (https://www.youtube.com/watch?v=LSNQuFEDOyQ)
##
## Usage:
## a = exp_decay(a, b, decay, delta)
##
## `a` and `b` are the start and end points respectively

## `decay` is the exponential decay constant,
## useful range approx 1 to 25 (slow to fast)
## `delta` is the time elapsed since last frame (shocker)
func exp_decay(a: Variant, b: Variant, decay: float, delta: float):
	return b+(a-b)*exp(-decay*delta)

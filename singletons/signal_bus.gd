extends Node

## Used for transfering signals across scenes/nodes or across nodes that may
## not exist yet

# These signals are not used until runtime, as some of the nodes are not
# immediately initialized, so the editor thinks they're unused
@warning_ignore_start("unused_signal")
# Hooks
signal game_started
signal game_ended
signal menu_loaded
@warning_ignore_restore("unused_signal")

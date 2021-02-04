extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func unlock_buildContruction():
	$build_buttons.buildConstructionAllow()
	
	pass

func lock_buildContruction():
	$build_buttons.buildConstructionDisable()
	pass

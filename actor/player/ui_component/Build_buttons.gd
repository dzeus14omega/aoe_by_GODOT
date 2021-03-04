extends Control

var output
var parent


# Called when the node enters the scene tree for the first time.
func _ready():
	parent = self.get_parent().get_parent()
	buildConstructionDisable()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func buildConstructionAllow():
	#print("button allow")
	$listButton/buildBarrack.disabled = false
	$listButton/buildGoldMine.disabled = false
	$listButton/buildTower.disabled = false
	pass

func buildConstructionDisable():
	#print("button disable")
	$listButton/buildBarrack.disabled = true
	$listButton/buildGoldMine.disabled = true
	$listButton/buildTower.disabled = true
	pass

func _on_buildGoldMine_button_up():
	parent.buildConstruction(0)
	pass # Replace with function body.


func _on_buildBarrack_button_up():
	parent.buildConstruction(1)
	pass # Replace with function body.


func _on_buildTower_button_up():
	parent.buildConstruction(2)
	pass # Replace with function body.

func _on_buildWall_button_up():
	#print("build wall")
	#parent.buildWall()
	parent.buildConstruction(3)
	pass # Replace with function body.

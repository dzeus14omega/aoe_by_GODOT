class_name Construction extends StaticBody2D 

var _hp
var _buildTime
var _cost
var _colorString = "ffffff"
var positionPoint : MinePoint = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_colorFromKing(colorString : String):
	self._colorString = colorString
	if (self.has_node("Sprite")):
		$Sprite.set_modulate(Color(_colorString))

func destruction():
	#hide()
	#get_parent().remove_child(self)
	queue_free()
	pass

sync func destroy():
	if (positionPoint != null):  # for construction is wall
		positionPoint.construction = null
	queue_free()
	pass

func checkExist():
	if self._hp <= 0 and is_network_master():
		rpc("destroy")

func force_Destroy():
	if is_network_master():
		rpc("destroy")

func getBuildTime():
	return _buildTime

func getHp():
	return _hp

func getCost():
	return _cost

func setHp(hp):
	self._hp = hp

func setBuildTime(time):
	self._buildTime = time

func setCost(cost):
	self._cost = cost

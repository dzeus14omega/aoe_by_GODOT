class_name Construction extends StaticBody2D

var _hp
var _buildTime
var _cost

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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

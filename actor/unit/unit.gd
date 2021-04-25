class_name Unit extends KinematicBody2D

var _hp
var _timelife
var _damage
var _timePerHit
var _range
var _speed
var _trainTime
var _cost
var _ownKing

func _ready():
	pass # Replace with function body.

func getTrainTime():
	return  _trainTime

func getCost():
	return _cost

func checkAlive():
	if self._hp <= 0 and is_network_master():
		rpc("destroyed")

func damaged(dam):
	if (self.get_node("blood_effect") != null):
		self.get_node("blood_effect").emitting = true
	self._hp -= dam
	pass

sync func destroyed():
	queue_free()
	pass

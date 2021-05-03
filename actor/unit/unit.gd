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
	if (self.has_node("AnimationBlooding")):
		if not $AnimationBlooding.is_playing():
			$blood_effect.restart()
			$AnimationBlooding.play("bleeding")
	self._hp -= dam
	pass

sync func destroyed():
	queue_free()
	pass

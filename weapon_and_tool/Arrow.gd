class_name Arrow extends Area2D


var _speed = 1800
#var _direction : Vector2 #motion -> normalized()
var _dam : int
var _life_time = 2.0
#var _startDirection : Vector2
var _truePosition : Vector2
var _trueDirection : float

func _init():
	pass

func init(dam):
	#self._direction = direction
	self._dam = dam
	#self._startDirection = direction
	pass

func _ready():
	$Timer.set_wait_time(_life_time)
	$Timer.start()
	set_process(false)
	
	pass # Replace with function body.

func fly():
	_truePosition = self.global_position
	_trueDirection = self.global_rotation
	set_process(true)
	pass

func _process(delta):
	#look_at(_startDirection)
	var velocity : Vector2
	velocity = Vector2(cos(_trueDirection), sin(_trueDirection)) * _speed
	_truePosition += velocity * delta
	self.global_position = _truePosition
	self.global_rotation = _trueDirection
	pass



func _on_arrow_body_entered(body):
	#target = body
	if (body.get_network_master() != self.get_network_master()):
		if body.has_method("damaged"):
			body.damaged(_dam)
		$Timer.stop()
		#rpc("destruction")
		queue_free()
	else:
		return
	
#	if is_network_master():
#		if (body.get_network_master() != self.get_network_master()):
#			rpc("hit")
#			$Timer.stop()
#			rpc("destruction")
#			pass
#		pass
	pass # Replace with function body.

func _on_Timer_timeout():
	queue_free()
	#rpc("destruction")
	pass # Replace with function body.

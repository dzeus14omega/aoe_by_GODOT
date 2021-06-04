class_name Bullet extends Area2D

var _speed = 1500

#var _direction : Vector2 #motion -> normalized()
var _dam : int
var _life_time = 2.0
var target
var _startPosition : Vector2
var _startDirection : Vector2

#puppet control
puppet var puppet_pos

func _init():
	pass

func init(direction, position, dam, life_time):
	#self._direction = direction
	self._dam = dam
	self._life_time = life_time
	self._startPosition = position
	self._startDirection = direction
	pass

func _ready():
	self.global_position = _startPosition
	if _startDirection.x != 0 and _startDirection.y != 0:
		if _startDirection.y ==0:
			if _startDirection.x <0:
				$bulletSprite.rotation = PI
			else:
				$bulletSprite.rotation = -PI
		else :
			if _startDirection.y <0:
				$bulletSprite.rotation = -atan(_startDirection.x/_startDirection.y)
			else :
				$bulletSprite.rotation = -atan(_startDirection.x/_startDirection.y) + PI
	
	
	#self.look_at(_startDirection)
	#print(_startDirection)
	$Timer.set_wait_time(_life_time)
	$Timer.start()
#	if is_network_master():
#		$Timer.start()

	pass # Replace with function body.

func _process(delta):
	var velocity : Vector2
	velocity = _startDirection * _speed
	self.global_position += velocity * delta
	
#	if is_network_master():
#		var velocity : Vector2
#		velocity = _direction * _speed
#		self.global_position += velocity * delta
#		rset("puppet_pos", global_position)
#	else:
#		self.global_position = puppet_pos
	pass



func _on_bullet_body_entered(body):
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

#sync func hit():
#	if target != null:
#		#target.damaged(_dam)
#		pass
#	pass
#
#sync func destruction():
#	hide()
#	get_parent().remove_child(self)
#	queue_free()
#	pass
#


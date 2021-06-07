class_name Archer extends Unit

var main_target = null
var targetInRange = null
var _direction : Vector2
var _arrowID = 0

#puppet control
puppet var puppet_pos = Vector2()
puppet var puppet_rotation = 0
puppet var puppet_direction = Vector2()

func init(mKing):
	.init(mKing)
	self._trainTime = 5
	self._cost = 25
	self._speed = 160
	self._hp = 35
	self._damage = 15

func _init():
	self._trainTime = 5
	self._cost = 50
	self._speed = 160
	self._hp = 35
	self._damage = 15

func _ready():
	$healthBar.max_value = self._hp
	$AnimatedSprite.play("idle")
	pass # Replace with function body.

sync func attack(direction, peerID, arrowID):
	$direction/bow.shoot(direction, peerID, arrowID)
	pass


func _process(delta):
	.checkAlive()
	
	if self._hp < $healthBar.max_value:
		$healthBar.visible = true
		if self._hp < 0:
			$healthBar.value = 0
		else :
			$healthBar.value = self._hp
	
	
	#set value for main target
	._process(delta)
	if is_network_master() and get_parent() != null:
		_find_closestEnemy()
		if main_target ==null:
			main_target = get_parent().get_parent().get_mainTarget()
		#print(main_target)
		
		if (is_instance_valid(main_target)):
			_rotate_to_mainTarget()
			if state_command == 0:
				if targetInRange != null:
					if not $direction/bow/shoot.is_playing():
						rpc("attack", self._direction, self.get_network_master(), _arrowID)
						_arrowID +=1
					playMovementAnimation(Vector2(0,0))
				else:
					_move_to_main_Target()
					playMovementAnimation(_direction)
				pass
			if state_command == 1:
				#move to King and keep distance around King
				move_to_King()
				pass
			rset("puppet_rotation", $direction.rotation)
			rset("puppet_pos", self.global_position)
			rset("puppet_direction", _direction)
	else:
		$direction.rotation = puppet_rotation
		#playMovementAnimation(puppet_pos - self.position)
		playMovementAnimation(puppet_direction)
		self.position = puppet_pos
		
	
	pass

func playMovementAnimation(motion : Vector2):
	if (motion == Vector2(0,0)):
		$AnimatedSprite.play("idle")
		return
	if (motion.y >= 0):
		if motion.y >= abs(motion.x):
			$AnimatedSprite.play("moveForward")
		else:
			$AnimatedSprite.play("moveLeft")
			if (motion.x > 0):
				$AnimatedSprite.flip_h = true
			else:
				$AnimatedSprite.flip_h = false
	else:
		if -motion.y >= abs(motion.x):
			$AnimatedSprite.play("moveBackward")
		else:
			$AnimatedSprite.play("moveLeft")
			if (motion.x > 0):
				$AnimatedSprite.flip_h = true
			else:
				$AnimatedSprite.flip_h = false
	pass

func move_to_King():
	#print(_ownKing.global_position)
	
	var motion = Vector2(_ownKing.global_position.x - self.global_position.x, _ownKing.global_position.y - self.global_position.y)
	motion = motion.normalized()
	self._direction = motion
	
	var disToKing = self.global_position.distance_to(_ownKing.global_position)
	if disToKing > 200:
		$direction.look_at(- _ownKing.global_position)
		move_and_slide(self._direction * _speed)
		playMovementAnimation(_direction)
	elif disToKing < 100 :
		move_and_slide(-self._direction * _speed)
		playMovementAnimation(_direction)
	else:
		_direction = Vector2(0,0)
		playMovementAnimation(_direction)
		if targetInRange != null:
			if not $direction/bow/shoot.is_playing():
				rpc("attack", self._direction, self.get_network_master(), _arrowID)
				_arrowID +=1
			
	pass

func _rotate_to_mainTarget():
	if (is_instance_valid(main_target)):
		$direction.look_at(main_target.global_position)
		var motion = Vector2(main_target.global_position.x - self.global_position.x, main_target.global_position.y - self.global_position.y)
		motion = motion.normalized()
		self._direction = motion
	pass

func _move_to_main_Target():
	if is_instance_valid(main_target):
		move_and_slide(self._direction * _speed)
	pass

func _find_closestEnemy():
	var bodies = $view_range.get_overlapping_bodies()
	var closestEnemy = null
	var minDist = 10000;
	
	for body in bodies:
		if body.get_network_master() != self.get_network_master() and body is PhysicsBody2D and body.name != "mapCollision":
			var dist = self.global_position.distance_to(body.global_position)
			if dist < minDist:
				minDist = dist
				closestEnemy = body
	self.main_target = closestEnemy
	self.targetInRange = closestEnemy

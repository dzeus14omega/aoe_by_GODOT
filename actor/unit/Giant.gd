class_name Giant extends Unit

var main_target = null

var _direction : Vector2
#puppet control
puppet var puppet_pos = Vector2()
puppet var puppet_rotation = 0

#for instance in trainButton
func init(mKing):
	.init(mKing)
	self._trainTime = 10
	self._cost = 150
	self._speed = 140
	self._hp = 450
	self._damage = 30

# for init when create new
func _init():
	self._trainTime = 10
	self._cost = 150
	self._speed = 140
	self._hp = 450
	self._damage = 30

func _ready():
	$healthBar.max_value = self._hp
	$AnimatedSprite.play("move")
	pass # Replace with function body.

sync func attack():
	$direction/ironPunch.attack()
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
	if get_parent().is_network_master() and get_parent() != null:
		_find_closestEnemy()
		if main_target ==null:
			main_target = get_parent().get_parent().get_mainTarget()
		#print(main_target)
		
		if (is_instance_valid(main_target)):
			_rotate_to_mainTarget()
			if state_command == 0:
				_move_to_main_Target()
				
				
				pass
			if state_command == 1:
				#move to King and keep distance around King
				move_to_King()
				pass
			rset("puppet_rotation", $direction.rotation)
			rset("puppet_pos", self.global_position)
	else:
		$direction.rotation = puppet_rotation
		$AnimatedSprite.visible = true
		$sprite.visible = false
		self.position = puppet_pos
	
	
	# attack main target if getting close
	if is_instance_valid(main_target) and is_network_master():
		var disToTarget = self.global_position.distance_to(main_target.global_position)
		#print(disToTarget)
		if disToTarget < 150:
			if not $direction/ironPunch/punch_attack.is_playing():
				rpc("attack")
				#print("attck call in soldier")
			#else:
				#print("deny attack")
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
		var real_motion = move_and_slide(self._direction * _speed)
		playMovementAnimation(real_motion)
	pass

func playMovementAnimation(real_motion):
	if real_motion != Vector2(0,0):
		$AnimatedSprite.visible = true
		$sprite.visible = false
	else:
		$AnimatedSprite.visible = false
		$sprite.visible = true

func move_to_King():
	#print(_ownKing.global_position)
	
	var motion = Vector2(_ownKing.global_position.x - self.global_position.x, _ownKing.global_position.y - self.global_position.y)
	motion = motion.normalized()
	self._direction = motion
	
	var disToKing = self.global_position.distance_to(_ownKing.global_position)
	if disToKing > 250:
		$direction.look_at(- _ownKing.global_position)
		var real_motion = move_and_slide(self._direction * _speed)
		playMovementAnimation(real_motion)
		#playMovementAnimation(_direction)
	elif disToKing < 150 :
		var real_motion = move_and_slide(-self._direction * _speed)
		playMovementAnimation(real_motion)
		#playMovementAnimation(_direction)
	else:
		playMovementAnimation(Vector2(0,0))
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



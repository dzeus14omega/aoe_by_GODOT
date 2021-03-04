class_name Archer extends Unit

var main_target = null
var targetInRange = null

var state_command : int = 0  #0:attack  1:defense
var _direction : Vector2

#puppet control
puppet var puppet_pos = Vector2()
puppet var puppet_rotation = 0


func init():
	self._trainTime = 5
	self._cost = 25
	self._speed = 260
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
	pass # Replace with function body.

sync func attack(direction, peerID):
	$bow.shoot(direction, peerID)
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
	if is_network_master() and get_parent() != null:
		_find_closestEnemy()
		if main_target ==null:
			main_target = get_parent().get_parent().get_mainTarget()
		#print(main_target)
		
		if (main_target != null):
			_rotate_to_mainTarget()
			if state_command == 0:
				if targetInRange != null:
					if not $bow/shoot.is_playing():
						rpc("attack", self._direction, self.get_network_master())
				else:
					_move_to_main_Target()
				pass
			if state_command == 1:
				#move to King and keep distance around King
				
				pass
			rset("puppet_rotation", self.rotation)
			rset("puppet_pos", self.global_position)
	else:
		self.rotation = puppet_rotation
		self.position = puppet_pos
	pass

func _rotate_to_mainTarget():
	self.look_at(main_target.global_position)
	var motion = Vector2(main_target.global_position.x - self.global_position.x, main_target.global_position.y - self.global_position.y)
	motion = motion.normalized()
	self._direction = motion
	pass

func _move_to_main_Target():
	if main_target != null:
		move_and_slide(self._direction * _speed)
	pass

func _find_closestEnemy():
	var bodies = $view_range.get_overlapping_bodies()
	var closestEnemy = null
	var minDist = 10000;
	
	for body in bodies:
		if body.get_network_master() != self.get_network_master() and body is PhysicsBody2D:
			var dist = self.global_position.distance_to(body.global_position)
			if dist < minDist:
				minDist = dist
				closestEnemy = body
	self.main_target = closestEnemy
	self.targetInRange = closestEnemy

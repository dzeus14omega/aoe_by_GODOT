class_name Soldier extends Unit

var main_target = null
var state_command : int = 0  #0:attack  1:defense
var rng = RandomNumberGenerator.new()

var _direction : Vector2
#puppet control
puppet var puppet_pos = Vector2()
puppet var puppet_rotation = 0

func _init():
	self._trainTime = 3
	self._cost = 20
	self._speed = 235
	self._hp = 45
	self._damage = 20
	

func init():
	self._trainTime = 3
	self._cost = 20
	self._speed = 135
	self._hp = 45
	self._damage = 20

func _ready():
	$healthBar.max_value = self._hp
	pass # Replace with function body.

sync func attack(random_number):
	$shortSword.attack(random_number)
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
		
		if (main_target != null):
			_rotate_to_mainTarget()
			if state_command == 0:
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
	
	
	# attack main target if getting close
	if main_target != null and is_network_master():
		var disToTarget = self.global_position.distance_to(main_target.global_position)
		#print(disToTarget)
		if disToTarget < 120:
			rng.randomize()
			var random_number = rng.randf_range(0,1)
			if not $shortSword/slash_atk.is_playing():
				rpc("attack", random_number)
				#print("attck call in soldier")
			#else:
				#print("deny attack")
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


class_name Soldier extends Unit

var main_target = null
var state_command : int = 0  #0:attack  1:defense

#puppet control
puppet var puppet_pos = Vector2()
puppet var puppet_rotation = 0

func _init():
	self._trainTime = 3
	self._cost = 20
	self._speed = 155
	self._hp = 45
	

func init():
	self._trainTime = 3
	self._cost = 20
	self._speed = 155
	self._hp = 45

func _ready():
	$healthBar.max_value = self._hp
	pass # Replace with function body.

sync func attack():
	pass

func _move_to_kingEnemy():
	if main_target != null:
		self.look_at(main_target.global_position)
		var motion = Vector2(main_target.global_position.x - self.global_position.x, main_target.global_position.y - self.global_position.y)
		
		motion = motion.normalized()
		#print(motion)
		move_and_slide(motion * _speed)
	pass

func _process(delta):
	.checkAlive()
	
	if self._hp < $healthBar.max_value:
		$healthBar.visible = true
		$healthBar.value = self._hp
	
	if get_parent().is_network_master() and get_parent() != null:
		main_target = get_parent().get_parent().get_mainTarget()
		#print(main_target)
		if (main_target != null):
			if state_command == 0:
				_move_to_kingEnemy()
				pass
			if state_command == 1:
				pass
			rset("puppet_rotation", self.rotation)
			rset("puppet_pos", self.global_position)
	else:
		self.rotation = puppet_rotation
		self.position = puppet_pos
	pass



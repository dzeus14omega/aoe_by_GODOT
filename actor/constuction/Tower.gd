class_name Tower extends Construction

var timePerHit = 1.0
var tower_dam = 30
var loading_statement : int  #0:ready 1:loading
var curent_enemy
#var listBodyInRange = []

var _bullet = preload("res://actor/constuction/construction_assets/Bullet.tscn")
var _bulletID = 0

func _init():
	self._hp = 400
	self._buildTime = 5
	self._cost = 75



func _ready():
	set_process(false)
	#print(get_network_master())
	$healthBar.max_value = _hp
	$AnimationConstruct.play("construct_finished")
	#print($range.get_overlapping_bodies().size())
	pass # Replace with function body.

func start_Process():
	set_process(true)

func _process(delta):
	.checkExist()
	
	if self._hp < $healthBar.max_value:
		$healthBar.visible = true
		if self._hp < 0:
			$healthBar.value = 0
		else :
			$healthBar.value = self._hp
#
	if is_network_master():
		curent_enemy = get_ClosestEnemy_inRange()
		#check loading_statement
		if loading_statement == 0:
			if curent_enemy != null:
				var direction = Vector2(curent_enemy.global_position.x - self.global_position.x,curent_enemy.global_position.y - self.global_position.y)
				direction = direction.normalized()
				#print(direction)
				#print(curent_enemy)
				rpc("shoot", direction, get_network_master(), _bulletID)
				_bulletID += 1
				loading_statement = 1 
				$ReloadTime.set_wait_time(timePerHit)
				$ReloadTime.start()
	pass

func _on_ReloadTime_timeout():
	loading_statement = 0
	pass # Replace with function body.


func get_ClosestEnemy_inRange():
	var listBody = $range.get_overlapping_bodies()
	
	#listBody.pop_back()  #pop itself
	
	if listBody.size() == 0:
		return null
	else:
		var closestBody : PhysicsBody2D = null
		var minDist = 10000
		
		#print("listBodyInRange size = " + String(listBodyInRange.size()))
		for body in listBody:
#			print("peer=====")
#			print(body.get_network_master())
#			print(self.get_network_master())
#			print("object")
			#print(body.name)
			if body.get_network_master() != self.get_network_master():
				#print("true")
				if (body.name != "mapCollision"):
					var dist = body.global_position.distance_to(self.global_position)
					if dist < minDist and dist > 0:
						minDist = dist
						closestBody = body
			else:
				#print("false")
				pass
		return closestBody


sync func shoot(direction : Vector2, peerID, bulletID):
	$sound_attack.play(0)
	var bullet = _bullet.instance()
	bullet.init(direction, self.global_position, tower_dam, 1.2)
	bullet.set_name(self.get_name() + String(bulletID))
	bullet.set_network_master(peerID)
	#print(bullet)
	#print(bullet.get_network_master())
	get_node("bulletList").add_child(bullet)
	pass

func damaged(dam):
	self._hp -= dam
	pass


#func _on_attackRange_body_entered(body):
#	listBodyInRange.append(body)
#	pass # Replace with function body.
#
#
#func _on_attackRange_body_exited(body):
#	listBodyInRange.erase(body)
#	pass # Replace with function body.

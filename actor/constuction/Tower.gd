class_name Tower extends Construction

var timePerHit = 1.0
var tower_dam = 30
var loading_statement : int  #0:ready 1:loading
var curent_enemy

var _bullet = preload("res://actor/constuction/construction_assets/Bullet.tscn")

func _init():
	self._hp = 400
	self._buildTime = 5
	self._cost = 50



func _ready():
	$healthBar.max_value = _hp
	pass # Replace with function body.

func _process(delta):
	if is_network_master():
		curent_enemy = get_ClosestEnemy_inRange()
		#check loading_statement
		if loading_statement == 0:
			if curent_enemy != null:
				var direction = Vector2(curent_enemy.global_position.x - self.global_position.x,curent_enemy.global_position.y - self.global_position.y)
				direction = direction.normalized()
				#print(direction)
				#print(curent_enemy)
				rpc("shoot", direction, get_network_master())
				
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
		for body in listBody:
			if body.get_network_master() != self.get_network_master():
				var dist = body.global_position.distance_to(self.global_position)
				if dist < minDist and dist > 0:
					minDist = dist
					closestBody = body
		return closestBody


sync func shoot(direction : Vector2, peerID):
	var bullet = _bullet.instance()
	bullet.init(direction, self.global_position, tower_dam, 1.2)
	bullet.set_network_master(peerID)
	#print(bullet)
	#print(bullet.get_network_master())
	get_node("bulletList").add_child(bullet)
	pass



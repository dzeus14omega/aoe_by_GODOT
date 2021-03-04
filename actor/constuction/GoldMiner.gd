class_name GoldMiner extends Construction

var link_myKing
var speedMine = 4 #second
var amountOfGold_perPull = 10

func _init():
	self._buildTime = 4
	self._cost = 50
	self._hp = 200

func _ready():
	print(link_myKing)
	$healthBar.max_value = _hp
	if is_network_master():
		$mining_cooldown.wait_time = speedMine
		$mining_cooldown.start()
	pass # Replace with function body.

func damaged(dam):
	self._hp -= dam
	pass

func _process(delta):
	.checkExist()
	
	if self._hp < $healthBar.max_value:
		$healthBar.visible = true
		if self._hp < 0:
			$healthBar.value = 0
		else :
			$healthBar.value = self._hp
	if is_network_master():
		#print($mining_cooldown.time_left)
		if $mining_cooldown.time_left == 0:
			#print("gain gold")
			link_myKing.gain_gold(amountOfGold_perPull)
			$mining_cooldown.start()
			
	
	


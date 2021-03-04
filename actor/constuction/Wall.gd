class_name Wall extends Construction

func _init():
	self._hp = 500
	self._buildTime = 5
	self._cost = 20

func _ready():
	$healthBar.max_value = _hp
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
	pass


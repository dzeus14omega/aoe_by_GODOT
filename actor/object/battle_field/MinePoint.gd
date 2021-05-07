class_name MinePoint extends Area2D

export var gold_capacity := 800
var construction

func _ready():
	$biome_animated.play()
	pass 

func set_contruction(_construction):
	$biome_animated.visible = false
	_construction.positionPoint = self
	if self.construction == null:
		self.construction = _construction
	else:
		self.construction.destruction()
		self.construction = _construction
	pass

func _process(delta):
	if construction == null and $biome_animated.visible == false:
		$biome_animated.visible = true
	pass


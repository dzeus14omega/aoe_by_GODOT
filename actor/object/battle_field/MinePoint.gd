class_name MinePoint extends Area2D

export var gold_capacity := 800
var construction

func _ready():
	pass 

func set_contruction(_construction):
	if self.construction == null:
		self.construction = _construction
	else:
		self.construction.destruction()
		self.construction = _construction
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

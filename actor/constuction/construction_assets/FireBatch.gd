class_name FireBatch extends Node2D

var parent 

# Called when the node enters the scene tree for the first time.
func _ready():
	if (is_instance_valid(get_node("../healthBar"))):
		#print(get_node("../healthBar").get_name())
		pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

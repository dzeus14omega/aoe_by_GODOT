class_name IronPunch extends Area2D


var in_attack_range = []
var _dam : int

func _ready():
	if (get_parent() != null):
		self._dam = get_parent()._damage
	
#	var my_random_number = rng.randf_range(0,1)
#	print(my_random_number)
#
#	rng.randomize()
#	var random_number = rng.randf_range(0,1)
#	attack(random_number)
	pass # Replace with function body.

func attack():
	$punch_attack.play("punch")
	pass


func dealDamage():
	for body in in_attack_range:
		if (body.get_network_master() != self.get_parent().get_network_master()):
			if body.has_method("damaged"):
				if body is Construction:
					body.damaged(_dam * 2)
				else:
					body.damaged(_dam)



func _on_ironPunch_body_entered(body):
	in_attack_range.append(body)
	pass # Replace with function body.


func _on_ironPunch_body_exited(body):
	in_attack_range.erase(body)
	pass # Replace with function body.

class_name ShortSword extends Area2D

var in_attack_range = []
var _dam : int

func _ready():
	if (get_parent() != null):
		self._dam = get_parent().get_parent()._damage
	
#	var my_random_number = rng.randf_range(0,1)
#	print(my_random_number)
#
#	rng.randomize()
#	var random_number = rng.randf_range(0,1)
#	attack(random_number)
	pass # Replace with function body.

func attack(random_number):
	#print("attack")
	$sound_attack_slave.volume_db = gameUtils.get_VolumnSound()
	$sound_attack_stab.volume_db = gameUtils.get_VolumnSound()
	if (random_number >=0.5):
		$slash_atk.play("slash_stab")
	else:
		$slash_atk.play("slash_rounnd")
	pass


func dealDamage():
	for body in in_attack_range:
		if (body.get_network_master() != self.get_parent().get_network_master()):
			if body.has_method("damaged"):
				body.damaged(_dam)

func _on_shortSword_body_entered(body):
	in_attack_range.append(body)
	pass # Replace with function body.



func _on_shortSword_body_exited(body):
	in_attack_range.erase(body)
	pass # Replace with function body.

class_name FireBatch extends Node2D

var linkHealthBar 

# Called when the node enters the scene tree for the first time.
func _ready():
	if (is_instance_valid(get_node("../healthBar"))):
		#print(get_node("../healthBar").get_name())
		linkHealthBar = get_node("../healthBar")
		pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(linkHealthBar):
		var ratioHp = linkHealthBar.value / linkHealthBar.max_value
		if ratioHp < 1:
			if !$fireBurn.is_playing():
				$fireBurn.play(0.0)
			if ratioHp > 0.8:
				if $flame1.visible == false:
					get_node("flame1").visible = true
					get_node("flame1").play("default")
					$fireBurn.volume_db +=3
			elif ratioHp > 0.6:
				if $flame2.visible == false:
					$flame2.visible = true
					$flame2.play("default")
					$fireBurn.volume_db +=3
			elif ratioHp > 0.4:
				if $flame3.visible == false:
					$flame3.visible = true
					$flame3.play("default")
					$fireBurn.volume_db +=3
			else:
				if $flame4.visible == false:
					$flame4.visible = true
					$flame4.play("default")
					$fireBurn.volume_db +=3
	pass

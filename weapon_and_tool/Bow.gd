class_name Bow extends Node2D

var damage : int
var curent_enemy

var _arrow = preload("res://weapon_and_tool/Arrow.tscn")
var _arrow_onLoad = null

func _ready():
	if (get_parent() != null):
		self.damage = get_parent().get_parent()._damage
		pass
	pass # Replace with function body.


func shoot(direction, peerID, arrowID):
	var arrow = _arrow.instance()
	arrow.init(damage)
	arrow.set_name(self.get_name() + String(arrowID))
	arrow.set_network_master(peerID)
	get_node("arrow_patch").add_child(arrow)
	self._arrow_onLoad = arrow
	
	#set sound volumn
	$sound_attack.volume_db = gameUtils.get_VolumnSound()
	$shoot.play("shooting")
	pass

func _push_arrow():
	if is_instance_valid(_arrow_onLoad):
		_arrow_onLoad.fly()
		_arrow_onLoad = null
	pass


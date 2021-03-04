class_name Bow extends Node2D

var damage : int
var curent_enemy

var _arrow = preload("res://weapon_and_tool/Arrow.tscn")
var _arrow_onLoad = null

func _ready():
	if (get_parent() != null):
		self.damage = get_parent()._damage
		pass
	pass # Replace with function body.


func shoot(direction, peerID):
	var arrow = _arrow.instance()
	arrow.init(damage)
	arrow.set_network_master(peerID)
	get_node("arrow_patch").add_child(arrow)
	self._arrow_onLoad = arrow
	$shoot.play("shooting")
	pass

func _push_arrow():
	if _arrow_onLoad != null:
		_arrow_onLoad.fly()
		_arrow_onLoad = null
	pass


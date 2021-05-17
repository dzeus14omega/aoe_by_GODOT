class_name Unit extends KinematicBody2D

var _hp
var _timelife
var _damage
var _timePerHit
var _range
var _speed
var _trainTime
var _cost
var _ownKing
var _colorString = "ffffff"
var state_command : int = 0  #0:attack  1:defense

func init(mking):
	#print(mking)
	_ownKing = mking

func _ready():
	pass # Replace with function body.

func _process(delta):
	if _ownKing != null:
		state_command = _ownKing.get_command_State()

func getTrainTime():
	return  _trainTime

func getCost():
	return _cost

func checkAlive():
	if self._hp <= 0 and is_network_master():
		rpc("destroyed")

func force_Kill():
	if is_network_master():
		rpc("destroyed")

func damaged(dam):
	if (self.has_node("AnimationBlooding")):
		if not $AnimationBlooding.is_playing():
			$blood_effect.restart()
			$AnimationBlooding.play("bleeding")
	self._hp -= dam
	pass

func set_colorFromKing(colorString : String):
	self._colorString = colorString
	if (self.has_node("sprite")):
		$sprite.set_modulate(Color(_colorString))
	if (self.has_node("AnimatedSprite")):
		$AnimatedSprite.set_modulate(Color(_colorString))

sync func destroyed():
	queue_free()
	pass

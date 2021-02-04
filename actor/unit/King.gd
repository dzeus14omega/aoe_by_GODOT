class_name King extends KinematicBody2D


var joystick_move
var speed = 150
var rotationSpeed = 100
var _minePoint : int


var ui = preload("res://actor/player/UI.tscn")
var _wall = preload("res://actor/constuction/Wall.tscn")
var _goldmine = preload("res://actor/constuction/GoldMiner.tscn")
var _barrack = preload("res://actor/constuction/Barrack.tscn")
var _tower = preload("res://actor/constuction/Tower.tscn")


var TIME_BUILD_GOLDMINE = 8
var TIME_BUILD_TOWER = 4
var TIME_BUILD_BARRACK = 8
var TIME_BUILD_WALL = 5

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
puppet var puppet_rotation = 0
var current_anim = ""

var outFit 

var _tmpPosBuilding := Vector2(0,0)
var _curBuildConstruction: Construction


func _ready():
	puppet_pos = position
	if is_network_master():
		#add camera2d
		var cam = Camera2D.new()
		cam._set_current(true)
		add_child(cam)
		#add ui
		var main_ui = ui.instance()
		add_child(main_ui)
		self.joystick_move = main_ui.get_node("Joystick")

func _physics_process(_delta):
	#print($direction/wall_shadow.global_position)
	var motion = _move(_delta)
	
	#TODO: stop any action when moving
	if (motion != Vector2(0,0) and $BuildingTimer.time_left >0 ):
		print("stop build")
		$BuildingTimer.stop()
	
	#TODO: show build progress
	if ($BuildingTimer.time_left != 0):
		_on_total_Building($BuildingTimer.time_left)
	
	if is_network_master():
		if motion.x != 0 and motion.y != 0:
			if motion.y ==0:
				if motion.x <0:
					$direction.rotation = PI
				else:
					$direction.rotation = -PI
			else :
				if motion.y <0:
					$direction.rotation = -atan(motion.x/motion.y)
				else :
					$direction.rotation = -atan(motion.x/motion.y) + PI
		rset("puppet_rotation",$direction.rotation)
	else:
		$direction.rotation = puppet_rotation
	
	#SET sprite direction
#	if motion.x < 0:
#		outFit.play("move_left")
#		outFit.flip_h = false
#	if motion.x > 0:
#		outFit.play("move_left")
#		outFit.flip_h = true
#	if motion.x == 0 and motion.y == 0:
#		outFit.play("idle")
#
#
	# FIXME: Use move_and_slide
	if not is_network_master():
		puppet_pos = position # To avoid jitter

func _move(delta: float) -> Vector2:
	var motion = Vector2(0,0)
	if is_network_master():
		if joystick_move and joystick_move.is_working:
			motion = joystick_move.output * speed
			#print(motion)
			move_and_slide(motion)
		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion
	return motion


func _isBuildWallAvailable():
	var tmp = $direction/buildWallArea.get_overlapping_bodies()
	if tmp.size() == 0:
		return true
	return false

sync func setup_wall(pos, rot):
	_curBuildConstruction.position = pos
	_curBuildConstruction.rotation = rot
	get_node("../Construction").add_child(_curBuildConstruction)
	_curBuildConstruction = null
	pass

sync func setup_Construction(pos):
	_curBuildConstruction.position = pos
	get_node("../Construction").add_child(_curBuildConstruction)
	instance_from_id(_minePoint).contruction = _curBuildConstruction
	_curBuildConstruction = null
	
	pass

func buildConstruction(type : int):  #0: gold mine, 1: barrack, 2: tower, 3: wall
	if type == 3:
		if _isBuildWallAvailable():
			_curBuildConstruction = _wall.instance()
			$BuildingTimer.wait_time = _curBuildConstruction.getBuildTime()
			_on_timeBuildingUpdate($BuildingTimer.wait_time)
			$buildProgress.visible = true
			$BuildingTimer.start()
			_tmpPosBuilding = self.position
			pass
		else:
			#TODO: display wall_shadow red to warnning
			pass
	else:
		if _minePoint != -1:
			match type:
				0:
					_curBuildConstruction = _goldmine.instance()
				1:
					_curBuildConstruction = _barrack.instance()
				2:
					_curBuildConstruction = _tower.instance()
			
			$BuildingTimer.wait_time = _curBuildConstruction.getBuildTime()
			_on_timeBuildingUpdate($BuildingTimer.wait_time)
			$buildProgress.visible = true
			$BuildingTimer.start()
			_tmpPosBuilding = self.position
			pass
	pass

func _on_BuildingTimer_timeout():
	if (self.position == _tmpPosBuilding):
		#build wall
		$buildProgress.visible = false
		if _curBuildConstruction is Barrack:
			_curBuildConstruction.mKing = self
			pass
			
			
		if _curBuildConstruction is Wall:
			rpc("setup_wall", $direction/buildWallArea.global_position, $direction.global_rotation)
		else:
			rpc("setup_Construction", instance_from_id(_minePoint).global_position)
		
#
#		if _curBuildConstruction is GoldMiner:
#			pass
#
#		if _curBuildConstruction is Tower:
#			pass
	pass # Replace with function body.

func _on_total_Building(time_left):
	$buildProgress.value = $buildProgress.max_value - time_left
	pass

func _on_timeBuildingUpdate(total_time):
	$buildProgress.max_value = total_time
	pass

func _on_minePoint_area_entered(area):
	if (area is MinePoint):
		if area.contruction == null or area.contruction.get_parent().get_parent() == self.get_parent():
			#print("enter mine point")
			_minePoint = area.get_instance_id()
			$UI.unlock_buildContruction()
	pass # Replace with function body.


func _on_minePoint_area_exited(area):
	if (area is MinePoint):
		if _minePoint != -1:
			#print("left mine point")
			_minePoint = -1
			$UI.lock_buildContruction()
		pass
	
	pass # Replace with function body.

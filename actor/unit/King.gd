class_name King extends KinematicBody2D

#UI control
var joystick_move
var speed = 150
var rotationSpeed = 100
var _minePoint

#Preload var
var ui = preload("res://actor/player/UI.tscn")

var _wall = preload("res://actor/constuction/Wall.tscn").instance()
var _goldmine = preload("res://actor/constuction/GoldMiner.tscn").instance()
var _barrack = preload("res://actor/constuction/Barrack.tscn").instance()
var _tower = preload("res://actor/constuction/Tower.tscn").instance()

#time build
#var TIME_BUILD_GOLDMINE = 8
#var TIME_BUILD_TOWER = 4
#var TIME_BUILD_BARRACK = 8
#var TIME_BUILD_WALL = 5

#puppet control
puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
puppet var puppet_rotation = 0

var current_anim = ""

var outFit 

#build control
var _tmpPosBuilding := Vector2(0,0)
var _curBuildType : int

## barrack manage var
var MAX_BARRACKCOUNT = 7
var cur_barrack_id = 0

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

#sync func setup_wall(pos, rot):
#	_curBuildConstruction.position = pos
#	_curBuildConstruction.rotation = rot
#	get_node("../Construction").add_child(_curBuildConstruction)
#	_curBuildConstruction = null
#	pass
#
#sync func setup_Construction(pos):
#	_curBuildConstruction.position = pos
#	get_node("../Construction").add_child(_curBuildConstruction)
#	_minePoint.set_contruction(_curBuildConstruction)
#	_curBuildConstruction = null
#
#	pass

sync func setup_Construction(pos,rot,type):
	var construction : Construction
	if type == 3:
		construction = _wall.duplicate()
		construction.rotation = rot
	else :
		match type:
			0:
				construction = _goldmine.duplicate()
			1:
				construction = _barrack.duplicate()
			2:
				construction = _tower.duplicate()
		
		#set barrack id if is barrack
		if (construction is Barrack):
			var barrackName = "barrack " + String(cur_barrack_id)
			construction.set_BarrackName(barrackName)
			cur_barrack_id += 1
		_minePoint.set_contruction(construction)
	construction.position = pos
	get_node("../Construction").add_child(construction)
	

func buildConstruction(type : int):  #0: gold mine, 1: barrack, 2: tower, 3: wall
	if is_network_master():
		_curBuildType = type
		if type == 3:
			if _isBuildWallAvailable():
				$BuildingTimer.wait_time = _wall.getBuildTime()
				_on_timeBuildingUpdate($BuildingTimer.wait_time)
				$buildProgress.visible = true
				$BuildingTimer.start()
				_tmpPosBuilding = self.position
				pass
			else:
				#TODO: display wall_shadow red to warnning
				pass
		else:
			if _minePoint != null:
				#manage number of barrack count
				var cur_barrackNum = 0;
				for child in get_parent().get_node("Construction").get_children():
					if child is Barrack:
						cur_barrackNum += 1
				if cur_barrackNum > MAX_BARRACKCOUNT - 1:
					return
				
				var construction : Construction
				
				match type:
					0:
						construction = _goldmine
					1:
						construction = _barrack
					2:
						construction = _tower
				
				
				$BuildingTimer.wait_time = construction.getBuildTime()
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
#		if _curBuildConstruction is Barrack:
#			_curBuildConstruction.set_mKing(self)
#			pass
			
#		if _curBuildConstruction is Wall:
#			rpc("setup_wall", $direction/buildWallArea.global_position, $direction.global_rotation)
#		else:
#			rpc("setup_Construction", _minePoint.global_position)
		if _curBuildType == 3:
			rpc("setup_Construction", $direction/buildWallArea.global_position, $direction.global_rotation, _curBuildType)
		else:
			rpc("setup_Construction", _minePoint.global_position, $direction.global_rotation, _curBuildType)
		_curBuildType == -1
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
#	if is_network_master():
	if (area is MinePoint):
		if area.construction == null or area.construction.get_parent().get_parent() == self.get_parent():
			#print("enter mine point")
			_minePoint = area
			if is_network_master():
				$UI.unlock_buildContruction()
	pass # Replace with function body.


func _on_minePoint_area_exited(area):
#	if is_network_master():
	if (area is MinePoint):
		if _minePoint != null:
			#print("left mine point")
			_minePoint = null
			if is_network_master():
				$UI.lock_buildContruction()
	
	pass # Replace with function body.

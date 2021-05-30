class_name King extends KinematicBody2D

#connection

#UI control
var joystick_move
var speed = 250
var rotationSpeed = 100
var _minePoint
var state_command : int = 0

var _hp = 250
var _colorString = "ffffff"
#Preload var
var ui = preload("res://actor/player/UI.tscn")

var _wall = preload("res://actor/constuction/Wall.tscn").instance()
var _goldmine = preload("res://actor/constuction/GoldMiner.tscn").instance()
var _barrack = preload("res://actor/constuction/Barrack.tscn").instance()
var _tower = preload("res://actor/constuction/Tower.tscn").instance()

#puppet control
puppet var puppet_pos = Vector2()
#puppet var puppet_motion = Vector2()
puppet var puppet_rotation = 0

var current_anim = ""

var outFit 
var _current_gold = 200


#build control
var _tmpPosBuilding := Vector2(0,0)
var _curBuildType : int
var _status : int = 0  #0: normal  1: building

## barrack manage var
var MAX_BARRACKCOUNT = 7
var cur_construction_id = 0

#Log final Results
var _total_gold = _current_gold
var _total_construction = 0
var _total_armyUnit = 0
var _total_pointHold = 0

func _ready():
	$healthBar.max_value = _hp
	$AnimatedSprite.play("move")
	
	puppet_pos = position
	if is_network_master():
		print("king ready here")
		print(get_tree().get_network_unique_id())
		print(get_network_master())
		#add camera2d
		var cam = Camera2D.new()
		cam._set_current(true)
		add_child(cam)
		#add ui and setup ui
		var main_ui = ui.instance()
		add_child(main_ui)
		self.joystick_move = main_ui.get_node("Joystick")
		
		main_ui.get_node("status/gold_amount").set_text(String(_current_gold))

func game_Victory():
	set_physics_process(false)
	gamestate.set_GameFinalResult_and_show(true, _total_construction, _total_armyUnit, _total_gold, get_parent().get_max_pointHolding())
	get_parent().destroy_All()
	rpc("destroyed")
	pass

func _physics_process(_delta):
	if self._hp <= 0 and is_network_master():
		gamestate.set_GameFinalResult_and_show(false, _total_construction, _total_armyUnit, _total_gold, get_parent().get_max_pointHolding())
		get_parent().destroy_All()
		rpc("destroyed")
#	if self._hp <= 0:
#		self.hide()
#		if is_network_master():
#			rpc("destroyed")
#			return
#		else:
#			return
	
	#cancel building
	if (self._status == 1):
		if (self.position != _tmpPosBuilding):
			rpc("stopBuildingAnimate")
			var returnGold = 0
			match _curBuildType:
				0:
					returnGold = _goldmine._cost
				1:
					returnGold = _barrack._cost
				2:
					returnGold = _tower._cost
				3:
					returnGold = _wall._cost
			
			#roll back gold refefund for total gold
			self._total_gold -= returnGold
			
			gain_gold(returnGold)
			$buildProgress.visible = false
			$BuildingTimer.stop()
			self._status = 0
	
	if self._hp < $healthBar.max_value:
		$healthBar.visible = true
		if self._hp < 0:
			$healthBar.value = 0
		else :
			$healthBar.value = self._hp
		
	#print($direction/wall_shadow.global_position)
	var motion = _move(_delta)
	
	#TODO: stop any action when moving
	if (motion != Vector2(0,0) and $BuildingTimer.time_left >0 ):
		#print("stop build")
		$BuildingTimer.stop()
	
	#TODO: show build progress
	if ($BuildingTimer.time_left != 0):
		_on_total_Building($BuildingTimer.time_left)
	
	if is_network_master():
		isBuildWallAvailable()
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
			
		if motion != Vector2(0,0):
			$AnimatedSprite.visible = true
			$Sprite.visible = false
			_playFootStep(true)
		else:
			$AnimatedSprite.visible = false
			$Sprite.visible = true
			_playFootStep(false)
		#rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		if puppet_pos != position:
			$AnimatedSprite.visible = true
			$Sprite.visible = false
			_playFootStep(true)
		else:
			$AnimatedSprite.visible = false
			$Sprite.visible = true
			_playFootStep(false)
		position = puppet_pos
		#motion = puppet_motion
	return motion

func _playFootStep(isPlay : bool):
	$footstep_sound.volume_db = gameUtils.get_VolumnSound()
	if isPlay:
		if !$footstep_sound.is_playing():
			$footstep_sound.play(0.0)
	else:
		$footstep_sound.stop()

func set_colorFromKingdom(colorString):
	self._colorString = colorString
	$Sprite.set_modulate(Color(colorString))
	$AnimatedSprite.set_modulate(Color(colorString))

func isBuildWallAvailable():
	var tmp = $direction/buildWallArea.get_overlapping_bodies()
	if tmp.size() == 0:
		if has_node("UI"):
			$UI/build_buttons.buildWallAllow()
		return true
	$UI/build_buttons.buildWallDisable()
	return false

sync func setup_Construction(pos, rot, type, peerID, constructID):
	var construction : Construction
	if type == 3:
		construction = _wall.duplicate()
		construction.rotation = rot
		construction.set_name("wall"+String(constructID))
		
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
			var barrackName = "barrack" + String(constructID)
			construction.set_BarrackName(barrackName)
			
		if (construction is GoldMiner):
			construction.set_name("goldmine" + String(constructID))
			#setup for gold mine
			if (get_network_master() == peerID):
				construction.link_myKing = self
				
		if (construction is Tower):
			construction.set_name("tower" + String(constructID))
			
		_minePoint.set_contruction(construction)
	construction.position = pos
	construction.set_network_master(peerID)
	construction.set_colorFromKing(self._colorString)
#	if is_network_master():
#		construction.set_colorFromKing(gamestate.player_info.colorString)
#	else:
#		construction.set_colorFromKing(gamestate.players[peerID].colorString)
	#print("set construction peer= " +String(peerID))
	get_node("../Construction").add_child(construction)
	pass

func buildConstruction(type : int):  #0: gold mine, 1: barrack, 2: tower, 3: wall
	if is_network_master():
		
		_curBuildType = type
		if type == 3:
			#if isBuildWallAvailable():
			if (spendGold_If_Possible(_wall._cost)):
				#manage status
				self._status = 1
				
				$BuildingTimer.wait_time = _wall.getBuildTime()
				_on_timeBuildingUpdate($BuildingTimer.wait_time)
				$buildProgress.visible = true
				$BuildingTimer.start()
				rpc("startBuildingAnimate")
				_tmpPosBuilding = self.position
			else:
				#TODO: Warn by UI gold
				pass
			#else:
				#TODO: display wall_shadow red to warnning
				
		else:
			#if _minePoint != null:
			if is_instance_valid(_minePoint):
				#manage number of barrack count
				var cur_barrackNum = 0;
				for child in get_parent().get_node("Construction").get_children():
					if child is Barrack:
						cur_barrackNum += 1
				if cur_barrackNum > MAX_BARRACKCOUNT - 1:
					#TODO: Warn in UI: max barrack count
					return
				
				var construction : Construction
				
				match type:
					0:
						construction = _goldmine
					1:
						construction = _barrack
					2:
						construction = _tower
				
				if spendGold_If_Possible(construction._cost):
					#manage status
					self._status = 1
					
					$BuildingTimer.wait_time = construction.getBuildTime()
					_on_timeBuildingUpdate($BuildingTimer.wait_time)
					$buildProgress.visible = true
					$BuildingTimer.start()
					rpc("startBuildingAnimate")
					_tmpPosBuilding = self.position
				else:
					#TODO: Warn by UI gold
					pass
	pass

sync func startBuildingAnimate():
	$AnimationBuilding.play("build")
	$building_sound.play(0)
	pass

sync func stopBuildingAnimate():
	$AnimationBuilding.stop()
	$building_sound.stop()
	$AnimationBuilding.seek(0, true)
	pass

func _on_BuildingTimer_timeout():
	self._status = 0;
	rpc("stopBuildingAnimate")
	
	if (self.position == _tmpPosBuilding):
		#build wall
		$buildProgress.visible = false
		_total_construction += 1
		if _curBuildType == 3:
			call_deferred("rpc", "setup_Construction",  $direction/buildWallArea.global_position, $direction.global_rotation, _curBuildType, get_network_master(), cur_construction_id)
			#rpc("setup_Construction", $direction/buildWallArea.global_position, $direction.global_rotation, _curBuildType, get_network_master(), cur_construction_id)
		else:
			call_deferred("rpc", "setup_Construction", _minePoint.global_position, $direction.global_rotation, _curBuildType, get_network_master(), cur_construction_id)
			#rpc("setup_Construction", _minePoint.global_position, $direction.global_rotation, _curBuildType, get_network_master(), cur_construction_id)
		_curBuildType == -1
		
		#for set name construction: unless error rpc method
		cur_construction_id += 1
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
		if area.construction == null || area.construction.get_parent().get_parent() == self.get_parent():
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

func set_command_State(state):
	self.state_command = state

func get_command_State():
	return state_command

func damaged(dam):
	if not $AnimationBleeding.is_playing():
		$blood_effect.restart()
		$AnimationBleeding.play("bleeding")
	self._hp -= dam
	pass

sync func destroyed():
	queue_free()
	pass


#currency management
func gain_gold(amountOfGold):
	self._current_gold += amountOfGold
	self._total_gold += amountOfGold
	$UI/status/gold_amount.set_text(String(checkGoldLeft()))
	pass

func spendGold_If_Possible(amountOfGold):
	if self._current_gold - amountOfGold >= 0:
		_current_gold -= amountOfGold
		$UI/status/gold_amount.set_text(String(checkGoldLeft()))
		return true
	else:
		return false

func checkGoldLeft():
	return self._current_gold

func add_total_armyUnit():
	_total_armyUnit += 1

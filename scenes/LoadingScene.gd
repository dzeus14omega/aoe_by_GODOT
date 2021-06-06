extends Control

var threads = []
var ListLoadedScene = {}

signal allThreadFinished()

onready var progress = $ColorRect/ProgressBar

func _ready():
	self.hide()
	pass # Replace with function body.

func _thread_load(pair):
	var key  = pair[0]
	var path = pair[1]
	#for path in ListPath:
	var ril = ResourceLoader.load_interactive(path)
	assert(ril)
	var total = ril.get_stage_count()
	# Call deferred to configure max load steps.
	print("mark x2")
	progress.call_deferred("set_max", (progress.value + total))
	print("mark x3")
	var res = null
	
	while true: #iterate until we have a resource
		# Update progress bar, use call deferred, which routes to main thread.
		#progress.call_deferred("set_value", (progress.value + ril.get_stage))
		print("mark x4")
		# Simulate a delay.
		#OS.delay_msec(0)
		# Poll (does a load step).
		var err = ril.poll()
		# If OK, then load another one. If EOF, it' s done. Otherwise there was an error.
		if err == ERR_FILE_EOF:
			# Loading done, fetch resource.
			res = ril.get_resource()
			break
		elif err != OK:
			# Not OK, there was an error.
			print("There was an error loading")
			break
	# Send whathever we did (or did not) get.
	call_deferred("_thread_done", res, key)

func _thread_done(resource, key):
	assert(resource)
	print("mark210")
	# Always wait for threads to finish, this is required on Windows.
	for thread in  threads:
		thread.wait_to_finish()
	
	# Hide the progress bar.
	#progress.hide()
	
	
	ListLoadedScene[key] = resource.instance()
	print("mark211")
	emit_signal("allThreadFinished")
	print("mark212")
	# Instantiate new scene.
#	var new_scene = resource.instance()
#	# Free current scene.
#	get_tree().current_scene.free()
#	get_tree().current_scene = null
#	# Add new one to root.
#
#	#sync should be place here
#	get_tree().root.add_child(new_scene)
#	# Set as current scene.
#	get_tree().current_scene = new_scene

func load_scene(pathList):
	$AnimationPlayer.play("fadeIn")
	ListLoadedScene.clear()
	progress.value = 0
	threads.clear()
	
	print("mark x1")
	for key in pathList:
		var thread = Thread.new()
		threads.append(thread)
		var pair = [key, pathList.get(key)]
		thread.start(self, "_thread_load", pair)
		
	raise()
	print("mark21")
	yield(self, "allThreadFinished")
	print("mark22")
	gamestate.emit_signal("loadResourceSuceeded")
	$AnimationPlayer.play("fadeOut")
	return ListLoadedScene



#func _process(delta):
#	pass

extends CanvasLayer

func update_TitleEnd():
	$EndingScene/TitleEnd/Label.text = gamestate.gameFinalResult
	pass

func update_totalConstruction():
	$EndingScene/StatBoard/total_construction.text = str(gamestate.total_construction)
	pass

func update_totalUnitTrain():
	$EndingScene/StatBoard/total_unitTrained.text = str(gamestate.total_unitTrain)
	pass

func update_totalGoldEarn():
	$EndingScene/StatBoard/total_gold.text = str(gamestate.total_goldEarn)
	pass

func update_totalPointHold():
	$EndingScene/StatBoard/max_pointHold.text = str(gamestate.total_pointHold)
	pass

func _on_BackButton_button_up():
	gamestate.reset_GameResult()
	gamestate.end_game()
	pass # Replace with function body.

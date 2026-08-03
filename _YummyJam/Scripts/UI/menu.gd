extends Control




func _on_play_bttn_pressed() -> void:
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/game.tscn")


func _on_controls_bttn_pressed() -> void:
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/controls.tscn")


func _on_credits_bttn_pressed() -> void:
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/credits.tscn")


func _on_exit_bttn_pressed() -> void:
	get_tree().quit()

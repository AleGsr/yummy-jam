extends Control

@onready var label_puntuacion: Label = $VBoxContainer/LabelScore
@onready var btn_reiniciar: Button = $VBoxContainer/Restart_bttn
@onready var btn_menu: Button = $VBoxContainer/Menu_bttn

func _ready() -> void:
	btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
	btn_menu.pressed.connect(_on_btn_menu_pressed)
	
	# Mostramos los puntos guardados en el script global
	label_puntuacion.text = "Puntuación Final: %d" % global.puntos_finales

func _on_btn_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/game.tscn")

func _on_btn_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/menu.tscn")

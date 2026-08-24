extends Area2D

var siendo_arrastrada: bool = false
var mouse_encima: bool = false
var offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	input_pickable = true
	# Conectamos las señales de cuando el mouse entra y sale de la fruta
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	mouse_encima = true

func _on_mouse_exited() -> void:
	mouse_encima = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Si hacemos clic y el mouse está sobre la fruta
		if event.pressed and mouse_encima:
			siendo_arrastrada = true
			offset = global_position - get_global_mouse_position()
			get_viewport().set_input_as_handled() # Le decimos a Godot que ya usamos este clic
		
		# Si soltamos el clic
		elif not event.pressed and siendo_arrastrada:
			siendo_arrastrada = false
			print("Fruta soltada en: ", global_position)

func _process(_delta: float) -> void:
	if siendo_arrastrada:
		global_position = get_global_mouse_position() + offset

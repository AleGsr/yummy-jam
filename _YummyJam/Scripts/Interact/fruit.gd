extends Area2D

var paso_actual: int = 0
var paso_por_banda: bool = false
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
			_verificar_drop() # Comprueba si cayó en una estación o basura
			print("Fruta soltada en: ", global_position)

func _process(_delta: float) -> void:
	if siendo_arrastrada:
		global_position = get_global_mouse_position() + offset
		
		
func _verificar_drop() -> void:
	var areas = get_overlapping_areas()
	for area in areas:
		# 1. Si cae en el Bote de Basura (comprobamos por nombre o por grupo "Trash")
		if area.name == "Trashcan" or area.is_in_group("Trash"):
			print("Fruta tirada a la basura.")
			queue_free()
			return
			
		# 2. Si cae en una Estación de trabajo
		elif area.has_method("procesar_ingrediente"):
			area.procesar_ingrediente(self)
			return

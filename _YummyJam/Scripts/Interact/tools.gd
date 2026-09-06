extends Area2D

@export var tipo_herramienta: String = "Regadera" # "Semillas", "Regadera" o "Tijeras"

var posicion_inicial: Vector2
var siendo_arrastrada: bool = false
var mouse_encima: bool = false
var offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	posicion_inicial = global_position
	input_pickable = true
	mouse_entered.connect(func(): mouse_encima = true)
	mouse_exited.connect(func(): mouse_encima = false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and mouse_encima:
			siendo_arrastrada = true
			offset = global_position - get_global_mouse_position()
			get_viewport().set_input_as_handled()
		elif not event.pressed and siendo_arrastrada:
			siendo_arrastrada = false
			_verificar_uso()

func _process(_delta: float) -> void:
	if siendo_arrastrada:
		global_position = get_global_mouse_position() + offset

func _verificar_uso() -> void:
	var fue_usada: bool = false
	var areas = get_overlapping_areas()
	
	for area in areas:
		if area.has_method("recibir_herramienta"):
			fue_usada = area.recibir_herramienta(tipo_herramienta)
			if fue_usada:
				break
				
	# Si no se usó en una maceta o lugar válido, vuelve a su posición original
	global_position = posicion_inicial

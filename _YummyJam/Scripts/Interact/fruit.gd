extends Area2D

signal cosechada

# Configuración y Estado
var paso_actual: int = 0
var paso_en_banda: bool = true # Inicia en true si nace de un arbusto o banda
var es_podrida: bool = false
var esta_cosechada: bool = false

var siendo_arrastrada: bool = false
var posicion_inicial: Vector2
var sobre_banda: bool = false
var velocidad_banda: Vector2 = Vector2.ZERO

@onready var visual: ColorRect = $Visual

func _ready() -> void:
	posicion_inicial = global_position
	# Detectar cuando entra o sale de una banda transportadora
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	# 1. Lógica de movimiento en la banda o arrastre
	if siendo_arrastrada:
		global_position = get_global_mouse_position()
	elif sobre_banda:
		global_position += velocidad_banda * delta

	# 2. Lógica de maduración/pudrición (SOLO si NO ha sido cosechada)
	if not esta_cosechada and not es_podrida:
		_procesar_maduracion(delta)

func _procesar_maduracion(_delta: float) -> void:
	# Si manejas la pudrición dentro de la fresa por tiempo, va aquí.
	pass

# Se llama cuando el jugador interactúa con la fresa o la mueve a la banda
func marcar_como_cosechada() -> void:
	esta_cosechada = true
	# Si tienes algún Timer adjunto para madurar/pudrir, lo detenemos:
	if has_node("TimerMaduracion"):
		$TimerMaduracion.stop()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			siendo_arrastrada = true
			z_index = 20
			
			# CONGELA la maduración inmediatamente al tomarla
			marcar_como_cosechada()
			cosechada.emit()
			
			# Cambia de padre de forma segura si venía de una maceta
			call_deferred("_desprender_de_maceta")
		else:
			if siendo_arrastrada:
				siendo_arrastrada = false
				z_index = 10
				_al_soltar_fresa()

func _desprender_de_maceta() -> void:
	var main_scene = get_tree().current_scene
	if get_parent() and get_parent() != main_scene:
		var pos_temp = global_position
		get_parent().remove_child(self)
		main_scene.add_child(self)
		global_position = pos_temp

func _al_soltar_fresa() -> void:
	var areas_debajo = get_overlapping_areas()
	var ubicacion_valida: bool = false
	var estacion_destino: Node = null

	for area in areas_debajo:
		if area.is_in_group("banda_transportadora") or area.is_in_group("arbustos") or area.is_in_group("caja_entrega"):
			ubicacion_valida = true
		elif area.is_in_group("estaciones"):
			ubicacion_valida = true
			estacion_destino = area

	if estacion_destino:
		estacion_destino.procesar_ingrediente(self)
	elif ubicacion_valida:
		posicion_inicial = global_position
	else:
		print("Ubicación no permitida. Regresando fresa...")
		global_position = posicion_inicial

func actualizar_apariencia() -> void:
	if not visual:
		return
		
	if es_podrida:
		visual.color = Color(0.3, 0.2, 0.1) # Marrón Podrido
		return

	match paso_actual:
		0:
			visual.color = Color(0.9, 0.1, 0.1) # Fresa limpia del arbusto
		1:
			visual.color = Color(0.3, 0.7, 0.9) # Lavada (Tono agua)
		2:
			visual.color = Color(0.9, 0.5, 0.1) # Cortada (Naranja/Trozos)
		3:
			visual.color = Color(0.7, 0.1, 0.3) # Cocinada (Rojo Oscuro/Mermelada)
		4:
			visual.color = Color(0.9, 0.9, 0.1) # Envasada (Tarro Final / Amarillo)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("banda_transportadora"):
		sobre_banda = true
		paso_en_banda = true
		marcar_como_cosechada() # Congelar si entra a la banda
		
		if "velocidad" in area:
			var vel_area = area.velocidad
			if vel_area is Vector2:
				velocidad_banda = vel_area
			elif vel_area is float or vel_area is int:
				velocidad_banda = Vector2(vel_area, 0)
			else:
				velocidad_banda = Vector2(100, 0)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("banda_transportadora"):
		sobre_banda = false
		velocidad_banda = Vector2.ZERO

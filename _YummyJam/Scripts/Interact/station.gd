extends Area2D

@export var paso_estacion: int = 1 # 1: Lavar, 2: Cortar, 3: Cocinar, 4: Envasar
@export var escena_fruta_procesada: PackedScene 

var ocupada: bool = false
var ingrediente_actual: Node = null

# Variables de interacción
var progreso_interaccion: float = 0.0
var progreso_requerido: float = 100.0

@onready var visual_estacion: ColorRect = $Visual

# Barra de progreso flotante
var barra_progreso: ProgressBar

func _ready() -> void:
	add_to_group("estaciones")
	_crear_barra_progreso_flotante()

func _crear_barra_progreso_flotante() -> void:
	# Creamos el nodo ProgressBar por código
	barra_progreso = ProgressBar.new()
	barra_progreso.custom_minimum_size = Vector2(80, 14)
	barra_progreso.show_percentage = false # Opcional: oculta el % textual si prefieres solo la barra llena
	
	# Posicionar la barra centrada arriba de la estación
	barra_progreso.position = Vector2(-40, -50) 
	barra_progreso.max_value = progreso_requerido
	barra_progreso.value = 0.0
	barra_progreso.visible = false # Se oculta por defecto
	
	add_child(barra_progreso)

func procesar_ingrediente(ingrediente: Node) -> void:
	if ocupada or not ingrediente:
		return
		
	if "es_podrida" in ingrediente and ingrediente.es_podrida:
		print("¡No se pueden procesar fresas podridas!")
		return

	var paso_fruta: int = 0
	var estuvo_en_banda: bool = false
	
	if "paso_actual" in ingrediente:
		paso_fruta = ingrediente.paso_actual
	if "paso_en_banda" in ingrediente:
		estuvo_en_banda = ingrediente.paso_en_banda
	
	if paso_fruta == (paso_estacion - 1):
		if not estuvo_en_banda and paso_estacion > 1:
			print("¡Debes pasar la fruta por la banda transportadora primero!")
			return

		ocupada = true
		ingrediente_actual = ingrediente
		ingrediente.queue_free()
		
		_iniciar_minijuego()
	else:
		print("Paso incorrecto para la Estación ", paso_estacion)

func _iniciar_minijuego() -> void:
	progreso_interaccion = 0.0
	
	# Mostrar y reiniciar la barra al comenzar
	if barra_progreso:
		barra_progreso.value = 0.0
		barra_progreso.visible = true
		
	if visual_estacion:
		visual_estacion.color = Color(0.9, 0.6, 0.2)

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if not ocupada:
		return

	# ESTACIÓN 1: Lavar (Mover el ratón sobre la estación)
	if paso_estacion == 1 and event is InputEventMouseMotion:
		_actualizar_progreso(event.relative.length() * 0.2)

	# ESTACIÓN 2: Cortar (Clics repetidos)
	elif paso_estacion == 2 and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_actualizar_progreso(25.0)

	# ESTACIÓN 3: Cocinar (Revolver manteniendo presionado)
	elif paso_estacion == 3 and event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_actualizar_progreso(event.relative.length() * 0.15)

	# ESTACIÓN 4: Envasar (Mantener presionado)
	elif paso_estacion == 4 and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_llenar_frasco()

func _llenar_frasco() -> void:
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and ocupada and paso_estacion == 4:
		_actualizar_progreso(5.0)
		if progreso_interaccion >= progreso_requerido:
			break
		await get_tree().create_timer(0.1).timeout

func _actualizar_progreso(cantidad: float) -> void:
	progreso_interaccion += cantidad
	
	# Actualizamos la barra de progreso en pantalla
	if barra_progreso:
		barra_progreso.value = progreso_interaccion
		
	_comprobar_finalizacion()

func _comprobar_finalizacion() -> bool:
	if progreso_interaccion >= progreso_requerido:
		_finalizar_procesamiento()
		return true
	return false

func _finalizar_procesamiento() -> void:
	# Ocultar la barra cuando termine la acción
	if barra_progreso:
		barra_progreso.visible = false
		
	if visual_estacion:
		visual_estacion.color = Color(0.2, 0.6, 0.2)
		
	ocupada = false
	_generar_fruta_procesada()

func _generar_fruta_procesada() -> void:
	if not escena_fruta_procesada:
		return

	var nueva_fruta = escena_fruta_procesada.instantiate()
	
	if "paso_actual" in nueva_fruta:
		nueva_fruta.paso_actual = paso_estacion
	
	if "paso_en_banda" in nueva_fruta:
		nueva_fruta.paso_en_banda = false
		
	get_tree().current_scene.add_child(nueva_fruta)
	nueva_fruta.global_position = global_position + Vector2(60, 0)
	nueva_fruta.z_index = 10
	
	if nueva_fruta.has_method("marcar_como_cosechada"):
		nueva_fruta.marcar_como_cosechada()
	
	if nueva_fruta.has_method("actualizar_apariencia"):
		nueva_fruta.actualizar_apariencia()

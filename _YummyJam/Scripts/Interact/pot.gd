extends Area2D

# Estados posibles del cultivo
enum Estado { VACIO, SEMBRADO, REGADO, LISTO, PODRIDO }
var estado_actual: Estado = Estado.VACIO

# Tiempos de espera (en segundos)
@export var tiempo_crecimiento: float = 2.0
@export var tiempo_para_podrirse: float = 4.0

var temporizador: float = 0.0
var mouse_encima: bool = false

# Precamargamos la escena de la fruta para instanciarla al cosechar
var escena_fruta = preload("res://_YummyJam/Scenes/Interact/fruit.tscn")

@onready var label_estado: Label = $LabelEstado

func _ready() -> void:
	input_pickable = true
	mouse_entered.connect(func(): mouse_encima = true)
	mouse_exited.connect(func(): mouse_encima = false)
	actualizar_interfaz()

func _process(delta: float) -> void:
	# Lógica según el estado del cultivo
	if estado_actual == Estado.REGADO:
		temporizador += delta
		if temporizador >= tiempo_crecimiento:
			estado_actual = Estado.LISTO
			temporizador = 0.0
			actualizar_interfaz()

	elif estado_actual == Estado.LISTO:
		temporizador += delta
		if temporizador >= tiempo_para_podrirse:
			estado_actual = Estado.PODRIDO
			actualizar_interfaz()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if mouse_encima:
			interactuar_con_maceta()

func interactuar_con_maceta() -> void:
	match estado_actual:
		Estado.VACIO:
			# 1. Siembra
			estado_actual = Estado.SEMBRADO
			print("1. Semilla sembrada")
			
		Estado.SEMBRADO:
			# 2. Riega
			estado_actual = Estado.REGADO
			temporizador = 0.0
			print("2. Planta regada, creciendo...")
			
		Estado.LISTO:
			# 3. Cosecha
			_cosechar_fruta()
			estado_actual = Estado.VACIO
			print("3. ¡Fruta cosechada!")
			
		Estado.PODRIDO:
			# Limpiar fruto pudrido
			estado_actual = Estado.VACIO
			print("Fruta podrida desechada. Maceta limpia.")
			
	actualizar_interfaz()

func _cosechar_fruta() -> void:
	# Crea una nueva fruta en la posición actual
	var nueva_fruta = escena_fruta.instantiate()
	get_parent().add_child(nueva_fruta)
	nueva_fruta.global_position = global_position

func actualizar_ui_texto() -> void: # Función auxiliar por consistencia
	actualizar_interfaz()

func actualizar_interfaz() -> void:
	if not is_node_ready():
		await ready
		
	if not label_estado:
		label_estado = get_node_or_null("LabelEstado")
	
	if label_estado:
		match estado_actual:
			Estado.VACIO:
				label_estado.text = "[Clic] Sembrar"
			Estado.SEMBRADO:
				label_estado.text = "[Clic] Regar"
			Estado.REGADO:
				label_estado.text = "Creciendo..."
			Estado.LISTO:
				label_estado.text = "[Clic] ¡Cosechar!"
			Estado.PODRIDO:
				label_estado.text = "[Clic] Limpiar Podrido"

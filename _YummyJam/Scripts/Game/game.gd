extends Node2D

@onready var label_timer: Label = $UI/LabelTimer
@onready var label_puntos: Label = $UI/LabelPoints
@onready var label_estacion: Label = $UI/LabelStation

# Nodos de la UI del Pedido
@onready var label_detalle: Label = $UI/OrderPanel/DetailLabel
@onready var label_tiempo_pedido: Label = $UI/OrderPanel/TimeLabel


# Variables del juego
var tiempo_restante: float = 180.0  # 3 minutos en segundos = 180
var puntos: int = 0
var estacion_actual: int = 1
var juego_terminado: bool = false


# Variables para el Pedido Activo
var pedido_activo: bool = false
var tiempo_pedido: float = 0.0
var producto_requerido: String = ""


# Lista de posibles recetas o productos
var productos_disponibles: Array[String] = [
	"Mermelada de Fresa"
]

# Nombres de tus 5 estaciones
var estaciones: Array[String] = [
	"1. Obtén base",
	"2. Lava",
	"3. Corta",
	"4. Cocina",
	"5. Envasa"
]

func _ready() -> void:
	actualizar_ui_texto()
	generar_nuevo_pedido()

func _process(delta: float) -> void:
	if juego_terminado:
		return
	
	# Cuenta regresiva del reloj
	if tiempo_restante > 0:
		tiempo_restante -= delta
		if tiempo_restante <= 0:
			tiempo_restante = 0
			_game_over()
		actualizar_reloj_visual()
		
	# Timer del pedido actual
	if pedido_activo:
		tiempo_pedido -= delta
		label_tiempo_pedido.text = "Tiempo pedido: %ds" % int(tiempo_pedido)
		if tiempo_pedido <= 0:
			print("¡El pedido expiró! Penalización de -100 puntos.")
			sumar_puntos(-100)
			generar_nuevo_pedido()
			
			
func generar_nuevo_pedido() -> void:
	pedido_activo = true
	tiempo_pedido = 45.0 # 45 segundos para entregar este pedido
	producto_requerido = productos_disponibles.pick_random()
	
	if label_detalle:
		label_detalle.text = "Entregar: " + producto_requerido
		
	
	
func entregar_producto(nombre_producto: String) -> void:
	if not pedido_activo:
		return

	if nombre_producto == producto_requerido:
		print("¡Pedido Entregado con Éxito! +1000 Puntos")
		sumar_puntos(1000)
		generar_nuevo_pedido()
	else:
		print("¡Producto Incorrecto! No coincide con el pedido.")
		sumar_puntos(-200)
		
		

func _unhandled_input(event: InputEvent) -> void:
	if juego_terminado:
		return
		
	if event is InputEventKey and event.pressed:
		# Detectar teclas numéricas [1 al 5]
		if event.keycode >= KEY_1 and event.keycode <= KEY_5:
			estacion_actual = event.keycode - KEY_1 + 1
			actualizar_ui_texto()
		
		# Detectar flechas para la banda transportadora
		elif event.keycode == KEY_LEFT:
			print("Banda: Moviendo hacia la IZQUIERDA")
		elif event.keycode == KEY_RIGHT:
			print("Banda: Moviendo hacia la DERECHA")

func sumar_puntos(cantidad: int) -> void:
	puntos += cantidad
	if puntos < 0:
		puntos = 0 # Evita puntos negativos
	
	# Guardamos directamente en el Autoload cada vez que cambian los puntos
	if "puntos_finales" in global:
		global.puntos_finales = puntos
		
	actualizar_ui_texto()

func actualizar_reloj_visual() -> void:
	var minutos: int = int(tiempo_restante) / 60
	var segundos: int = int(tiempo_restante) % 60
	label_timer.text = "Tiempo Global: %02d:%02d" % [minutos, segundos]
	
	
func actualizar_ui_texto() -> void:
	label_puntos.text = "Points: %d" % puntos
	label_estacion.text = "Estación Activa: " + estaciones[estacion_actual - 1]

func _game_over() -> void:
	juego_terminado = true
	print("¡TIEMPO AGOTADO! Puntuación Final: ", puntos)
	
	# Guardamos el puntaje en el Autoload
	global.puntos_finales = puntos
	
	# Cambiamos a la escena de GameOver
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/GameOver.tscn")

	

extends Node2D

@onready var label_timer: Label = $UI/PanelTop/LabelTimer
@onready var label_puntos: Label = $UI/PanelTop/LabelPoints
@onready var label_estacion: Label = $UI/PanelTop/LabelStation

# Variables del juego
var tiempo_restante: float = 60.0  # 3 minutos en segundos = 180
var puntos: int = 0
var estacion_actual: int = 1
var juego_terminado: bool = false

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
	actualizar_ui_texto()

func actualizar_reloj_visual() -> void:
	var minutos: int = int(tiempo_restante) / 60
	var segundos: int = int(tiempo_restante) % 60
	label_timer.text = "Time: %02d:%02d" % [minutos, segundos]

func actualizar_ui_texto() -> void:
	label_puntos.text = "Points: %d" % puntos
	label_estacion.text = "Estación Activa: " + estaciones[estacion_actual - 1]

func _game_over() -> void:
	juego_terminado = true
	print("¡TIEMPO AGOTADO! Puntuación Final: ", puntos)
	label_timer.text = "¡FIN DEL TIEMPO!"
	get_tree().change_scene_to_file("res://_YummyJam/Scenes/menu.tscn")
	

	

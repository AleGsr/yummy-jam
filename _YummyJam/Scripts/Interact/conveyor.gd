extends Area2D

# Velocidad de movimiento de la cinta
@export var velocidad: float = 80.0

# Dirección (-1 = Izquierda, 1 = Derecha)
var direccion: int = 1
var frutas_en_banda: Array[Node2D] = []

@onready var label_direccion: Label = $LabelDireccion

func _ready() -> void:
	# Solo conectamos las señales de áreas (ya que Fruta es un Area2D)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	actualizar_label()

func _process(delta: float) -> void:
	# Movemos cada fruta que esté reposando en la banda
	for fruta in frutas_en_banda:
		# Solo mover si la fruta existe y NO está siendo arrastrada por el mouse
		if is_instance_valid(fruta) and not fruta.get("siendo_arrastrada"):
			fruta.global_position.x += velocidad * direccion * delta

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Cambiar dirección con las flechas
		if event.keycode == KEY_LEFT:
			direccion = -1
			actualizar_label()
		elif event.keycode == KEY_RIGHT:
			direccion = 1
			actualizar_label()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Fruta") or area.name.begins_with("Fruta") or "siendo_arrastrada" in area:
		if not frutas_en_banda.has(area):
			frutas_en_banda.append(area)
			# Cambiamos "fruta" por "area" aquí:
			area.set("paso_por_banda", true)

func _on_area_exited(area: Area2D) -> void:
	if frutas_en_banda.has(area):
		frutas_en_banda.erase(area)

func actualizar_label() -> void:
	if label_direccion:
		if direccion == 1:
			label_direccion.text = "Banda: ---> (Derecha)"
		else:
			label_direccion.text = "Banda: <--- (Izquierda)"

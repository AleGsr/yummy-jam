extends Area2D

enum Estado { VACIO, SEMBRADO, FLORECIDO, CON_FRUTO, PODRIDO, MUERTO }
var estado_actual: Estado = Estado.VACIO

var riegos: int = 0

@onready var visual_planta: Sprite2D = $Bush
@onready var visual_deadplanta: Sprite2D = $DeadBush
@onready var visual_seeds: Sprite2D = $CultiveSeeds

@onready var visual_flores: CanvasItem = $Flower
@onready var contenedor_fresas: Node2D = $Strawberry
@onready var timer_maduracion: Timer = $TimerMaduracion

@export var escena_fruta: PackedScene # Asigna aquí tu Fruit.tscn en el Inspector

func _ready() -> void:
	timer_maduracion.timeout.connect(_on_timer_timeout)
	actualizar_visual()

func recibir_herramienta(tipo: String) -> bool:
	match estado_actual:
		Estado.VACIO:
			if tipo == "Semillas":
				estado_actual = Estado.SEMBRADO
				visual_seeds.visible = true
				riegos = 0
				actualizar_visual()
				return true
				
		Estado.SEMBRADO, Estado.FLORECIDO:
			if tipo == "Regadera":
				riegos += 1
				visual_seeds.visible = false
				if riegos == 1 and estado_actual == Estado.SEMBRADO:
					# 1er Riego tras sembrar: Sale el brote
					actualizar_visual()
				elif riegos == 2 or (estado_actual == Estado.SEMBRADO and riegos >= 1):
					# Riego para florecer
					estado_actual = Estado.FLORECIDO
					actualizar_visual()
					timer_maduracion.start(4.0) # 4 segundos para transformarse en fresas
				elif riegos >= 3:
					# Sobrerriego
					estado_actual = Estado.MUERTO
					timer_maduracion.stop()
					limpiar_fresas()
					actualizar_visual()
				return true

		Estado.MUERTO:
			if tipo == "Tijeras":
				estado_actual = Estado.VACIO
				riegos = 0
				limpiar_fresas()
				actualizar_visual()
				
				var main = get_tree().current_scene
				if main and main.has_method("sumar_puntos"):
					main.sumar_puntos(-50)
				return true
				
	return false

func _on_timer_timeout() -> void:
	if estado_actual == Estado.FLORECIDO:
		estado_actual = Estado.CON_FRUTO
		actualizar_visual()
		generar_fresas_agarrables()
		timer_maduracion.start(8.0) # Tiempo antes de podrirse si no se cosechan
		
	elif estado_actual == Estado.CON_FRUTO:
		estado_actual = Estado.PODRIDO
		actualizar_visual()
		marcar_fresas_podridas()

func generar_fresas_agarrables() -> void:
	limpiar_fresas()
	if not escena_fruta:
		print("¡ERROR! No asignaste la escena_fruta en el Inspector de la Maceta.")
		return

	# Coordenadas relativas a la maceta (Ajusta la Y si necesitas que salgan más arriba)
	var posiciones = [Vector2(-20, -35), Vector2(0, -50), Vector2(20, -35)]
	
	for pos in posiciones:
		var nueva_fresa = escena_fruta.instantiate()
		
		# Agregamos primero a la escena para inicializar sus nodos
		contenedor_fresas.add_child(nueva_fresa)
		
		# Posicionamos la fresa
		nueva_fresa.position = pos
		
		# Forzamos que se dibuje por ENCIMA de la maceta y la planta
		nueva_fresa.z_index = 10 
		
		# Nos aseguramos de que sea visible
		nueva_fresa.visible = true
		
		# Conectamos la señal de cosecha
		if nueva_fresa.has_signal("cosechada"):
			nueva_fresa.cosechada.connect(_on_fresa_cosechada)
			
	print("Fresas generadas exitosamente: ", contenedor_fresas.get_child_count())

func marcar_fresas_podridas() -> void:
	for fresa in contenedor_fresas.get_children():
		if "es_podrida" in fresa:
			fresa.es_podrida = true
			if fresa.has_method("actualizar_apariencia"):
				fresa.actualizar_apariencia()

func _on_fresa_cosechada() -> void:
	# Si ya cosechó todas las fresas de la maceta, la dejamos lista para volver a regar
	if contenedor_fresas.get_child_count() <= 1:
		estado_actual = Estado.SEMBRADO
		riegos = 1 # Lista para volver a florecer con 1 riego extra
		actualizar_visual()

func limpiar_fresas() -> void:
	for hijo in contenedor_fresas.get_children():
		hijo.queue_free()

func actualizar_visual() -> void:
	match estado_actual:
		Estado.VACIO:
			visual_planta.visible = false
			visual_deadplanta.visible = false
			visual_flores.visible = false
			print("Maceta vacía.")
		Estado.SEMBRADO:
			visual_planta.visible = (riegos >= 1)
			if visual_planta.visible:
				visual_planta.visible = true
			visual_flores.visible = false
			print("Semillas plantadas.")
		Estado.FLORECIDO:
			visual_planta.visible = true
			visual_flores.visible = true
			print("Flores brotadas.")
		Estado.CON_FRUTO, Estado.PODRIDO:
			visual_planta.visible = true
			visual_flores.visible = false
			print("Fresas salieron.")
		Estado.MUERTO:
			visual_planta.visible = false
			visual_deadplanta.visible = true
			visual_flores.visible = false
			print("Planta muerta.")

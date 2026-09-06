extends Area2D

@export var paso_final_requerido: int = 4 
@export var puntos_correctos: int = 1000
@export var puntos_penalizacion: int = 200

func _ready() -> void:
	add_to_group("caja_entrega")
	area_entered.connect(_on_fresa_ingresada)

func _on_fresa_ingresada(area: Area2D) -> void:
	# Verificamos si el nodo que entró tiene el paso de procesamiento
	if "paso_actual" in area:
		var paso: int = area.paso_actual
		var esta_podrida: bool = area.es_podrida if "es_podrida" in area else false
		var juego_principal = get_tree().current_scene

		if paso == paso_final_requerido and not esta_podrida:
			print("¡Entrega Perfecta! Procesando pedido...")
			# Le avisamos a game.gd para validar el pedido activo y sumar los puntos
			if juego_principal and juego_principal.has_method("entregar_producto"):
				juego_principal.entregar_producto("Mermelada de Fresa")
			elif juego_principal and juego_principal.has_method("sumar_puntos"):
				juego_principal.sumar_puntos(puntos_correctos)
		else:
			print("Producto incompleto (Paso ", paso, ") o podrido entregado. Penalizando...")
			if juego_principal and juego_principal.has_method("sumar_puntos"):
				juego_principal.sumar_puntos(-puntos_penalizacion)

		# Eliminamos la fresa procesada
		area.queue_free()

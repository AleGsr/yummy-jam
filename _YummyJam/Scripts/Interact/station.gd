extends Area2D

# Configuración de la estación (1: Lava, 2: Obtén base, 3: Corta, 4: Cocina, 5: Envasa)
@export var numero_estacion: int = 1
@export var nombre_estacion: String = "1. Lava"

@onready var label_nombre: Label = $LabelNombre

func _ready() -> void:
	if label_nombre:
		label_nombre.text = nombre_estacion

func procesar_ingrediente(fruta: Area2D) -> void:
	# 1. Verificar si la fruta pasó por la banda transportadora antes de esta estación
	var navego_en_banda: bool = fruta.get("paso_por_banda")
	if not navego_en_banda:
		print("Debes colocar la fruta en la banda transportadora antes de llevarla a esta estación")
		return

	# 2. Verificar si la fruta está podrida
	if fruta.get("estado_actual") == 4: # Estado.PODRIDO
		print("Intentaste procesar fruta podrida.")
		fruta.queue_free()
		return

	var paso_fruta: int = fruta.get("paso_actual")

	# 3. Verificar si la fruta entró a la estación correcta en el orden estricto
	if numero_estacion == paso_fruta + 1:
		# ¡Paso correcto! Avanzamos la receta de la fruta
		fruta.paso_actual = numero_estacion
		
		# Desactivamos el permiso de banda: deberá volver a tocar la cinta para ir al siguiente paso
		fruta.paso_por_banda = false
		
		print("Correcto. Paso %d completado en %s" % [fruta.paso_actual, nombre_estacion])
		
		# Actualizamos visualmente el texto en la fruta si tiene un Label
		var label_fruta = fruta.get_node_or_null("Label")
		if label_fruta:
			label_fruta.text = "Paso " + str(fruta.paso_actual)

		# Si completó el último paso (5. Envasa) -> Se empaca la mermelada y otorga puntos
		if fruta.paso_actual == 5:
			print("¡Mermelada lista y empacada!")
			var main = get_tree().current_scene
			if main and main.has_method("sumar_puntos"):
				main.sumar_puntos(500)
			fruta.queue_free() # Se destruye el producto terminado
			
	else:
		# Si la pones en una estación fuera de orden -> Se arruina la mezcla
		print("¡Error de orden! Intentaste usar la Estación %d pero la fruta va en el Paso %d." % [numero_estacion, paso_fruta])
		print("Producto arruinado. Se desecha.")
		fruta.queue_free()

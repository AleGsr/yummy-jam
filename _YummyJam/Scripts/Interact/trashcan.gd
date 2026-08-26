extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if "siendo_arrastrada" in area:
		print("Producto o fruta desechada en la basura.")
		area.queue_free() # Destruye el objeto tirado

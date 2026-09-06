extends Node

# Señal para notificar a la UI en tiempo real
signal puntos_cambiados(nuevos_puntos: int)

var puntos: int = 0

func agregar_puntos(cantidad: int) -> void:
	puntos += cantidad
	print("Puntos actualizados: ", puntos)
	puntos_cambiados.emit(puntos)

func restar_puntos(cantidad: int) -> void:
	puntos -= cantidad
	if puntos < 0:
		puntos = 0
	print("Puntos actualizados: ", puntos)
	puntos_cambiados.emit(puntos)

func reiniciar_puntos() -> void:
	puntos = 0
	puntos_cambiados.emit(puntos)

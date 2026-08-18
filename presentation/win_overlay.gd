class_name WinOverlay
extends Control

## Kazanç ekranı (placeholder, dilden bağımsız — metin yok, kodla çizilir).
## Görününce ekranı karartır + onay işareti çizer; dokununca yeniden başlatma ister.

signal continue_requested


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()


func show_win(screen_size: Vector2) -> void:
	size = screen_size
	position = Vector2.ZERO
	show()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if tapped:
		continue_requested.emit()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.55))
	var center := size / 2.0
	# onay işareti (check)
	draw_polyline(PackedVector2Array([
		center + Vector2(-48, 4),
		center + Vector2(-14, 40),
		center + Vector2(58, -46),
	]), Color(0.45, 0.9, 0.55), 10.0, true)

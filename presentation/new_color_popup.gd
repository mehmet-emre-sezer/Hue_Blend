class_name NewColorPopup
extends Control

## İlk kez bir renk keşfedilince kısa kutlama: renk büyük gösterilir, sonra solar.
## Girdiyi engellemez (oyun akışını durdurmaz).

var _card: ColorCard
var _show_symbol := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()


func celebrate(color: ColorCard, screen_size: Vector2, show_symbol: bool) -> void:
	size = screen_size
	position = Vector2.ZERO
	_card = color
	_show_symbol = show_symbol
	modulate.a = 1.0
	show()
	queue_redraw()
	var tween := create_tween()
	tween.tween_interval(0.9)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hide)


func _draw() -> void:
	if _card == null:
		return
	var box := 130.0
	var center := size / 2.0 - Vector2(0, 80)
	draw_circle(center, box * 0.72, Color(1, 1, 1, 0.12))  # hafif hâle
	var rect := Rect2(center - Vector2(box, box) / 2.0, Vector2(box, box))
	UnitVisual.draw_unit(self, rect, _card.display_color, _card.symbol_id, _show_symbol)

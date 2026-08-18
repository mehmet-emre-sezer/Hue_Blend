class_name TubeView
extends Node2D

## Tek tüpün görseli (placeholder — kodla çizilir). Çekirdeği OKUR, mantık içermez.
## Birimler renk + erişilebilirlik sembolü ile çizilir (TDD §2.3).
## Origin: sol-üst köşe.

const UNIT_HEIGHT := 62.0
const TUBE_WIDTH := 92.0
const PADDING := 6.0

var _tube: Tube
var _selected := false


func setup(tube: Tube) -> void:
	_tube = tube
	queue_redraw()


func set_selected(value: bool) -> void:
	if _selected == value:
		return
	_selected = value
	queue_redraw()


func tube_size() -> Vector2:
	var capacity := _tube.capacity() if _tube != null else 0
	return Vector2(TUBE_WIDTH, capacity * UNIT_HEIGHT)


## Yerel koordinatta bir nokta bu tüpün sınırları içinde mi (dokunuş isabeti için).
func contains_local(local_point: Vector2) -> bool:
	return Rect2(Vector2.ZERO, tube_size()).has_point(local_point)


func _draw() -> void:
	if _tube == null:
		return
	var height := _tube.capacity() * UNIT_HEIGHT
	var bounds := Rect2(0, 0, TUBE_WIDTH, height)

	draw_rect(bounds, Color(1, 1, 1, 0.06))  # tüp zemini

	var cards := _tube.cards_snapshot()  # dip→üst
	for i in cards.size():
		var card: ColorCard = cards[i]
		var y := height - (i + 1) * UNIT_HEIGHT
		var unit_rect := Rect2(PADDING, y + PADDING, TUBE_WIDTH - 2 * PADDING, UNIT_HEIGHT - 2 * PADDING)
		draw_rect(unit_rect, card.display_color)
		_draw_symbol(card.symbol_id, unit_rect.get_center(), 13.0)

	var outline := Color(1, 0.85, 0.4) if _selected else Color(1, 1, 1, 0.5)
	var outline_width := 4.0 if _selected else 2.0
	draw_rect(bounds, outline, false, outline_width)  # dış çizgi (seçiliyse vurgulu)


## Renk körü erişilebilirliği: her renge sabit, ayırt edilebilir bir şekil eşlenir.
func _draw_symbol(symbol_id: StringName, center: Vector2, radius: float) -> void:
	var ink := Color(0, 0, 0, 0.5)
	match symbol_id:
		&"circle":
			draw_circle(center, radius, ink)
		&"square":
			draw_rect(Rect2(center.x - radius, center.y - radius, radius * 2, radius * 2), ink)
		&"triangle":
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -radius),
				center + Vector2(radius, radius),
				center + Vector2(-radius, radius),
			]), ink)
		&"diamond":
			draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -radius),
				center + Vector2(radius, 0),
				center + Vector2(0, radius),
				center + Vector2(-radius, 0),
			]), ink)
		_:
			draw_circle(center, radius * 0.4, ink)

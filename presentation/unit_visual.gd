class_name UnitVisual
extends RefCounted

## Birim çiziminin TEK kaynağı (Clean §15: tekrar yok). Hem TubeView hem FlyingUnit kullanır.
## Layout sabitleri de burada (sihirli sayı yok, tek yer).

const UNIT_HEIGHT := 62.0
const TUBE_WIDTH := 92.0
const PADDING := 6.0
const SYMBOL_RADIUS := 13.0


static func unit_inner_size() -> Vector2:
	return Vector2(TUBE_WIDTH - 2 * PADDING, UNIT_HEIGHT - 2 * PADDING)


## Verilen canvas üzerine bir birimi çizer: renk dolgusu + erişilebilirlik sembolü.
static func draw_unit(canvas: CanvasItem, rect: Rect2, color: Color, symbol_id: StringName) -> void:
	canvas.draw_rect(rect, color)
	_draw_symbol(canvas, symbol_id, rect.get_center(), SYMBOL_RADIUS)


static func _draw_symbol(canvas: CanvasItem, symbol_id: StringName, center: Vector2, radius: float) -> void:
	var ink := Color(0, 0, 0, 0.5)
	match symbol_id:
		&"circle":
			canvas.draw_circle(center, radius, ink)
		&"square":
			canvas.draw_rect(Rect2(center.x - radius, center.y - radius, radius * 2, radius * 2), ink)
		&"triangle":
			canvas.draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -radius),
				center + Vector2(radius, radius),
				center + Vector2(-radius, radius),
			]), ink)
		&"diamond":
			canvas.draw_colored_polygon(PackedVector2Array([
				center + Vector2(0, -radius),
				center + Vector2(radius, 0),
				center + Vector2(0, radius),
				center + Vector2(-radius, 0),
			]), ink)
		_:
			canvas.draw_circle(center, radius * 0.4, ink)

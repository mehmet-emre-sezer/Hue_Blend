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


## Verilen canvas üzerine bir birimi çizer: renk dolgusu (+ isteğe bağlı renk körü sembolü).
static func draw_unit(canvas: CanvasItem, rect: Rect2, color: Color, symbol_id: StringName, show_symbol: bool) -> void:
	canvas.draw_rect(rect, color)
	if show_symbol:
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
		&"pentagon":
			_draw_ngon(canvas, center, radius, 5, ink)
		&"hexagon":
			_draw_ngon(canvas, center, radius, 6, ink)
		&"heptagon":
			_draw_ngon(canvas, center, radius, 7, ink)
		&"octagon":
			_draw_ngon(canvas, center, radius, 8, ink)
		&"ring":
			canvas.draw_arc(center, radius * 0.9, 0.0, TAU, 24, ink, 3.0)
		&"cross":
			canvas.draw_line(center + Vector2(-radius, -radius), center + Vector2(radius, radius), ink, 3.5)
			canvas.draw_line(center + Vector2(-radius, radius), center + Vector2(radius, -radius), ink, 3.5)
		&"plus":
			canvas.draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), ink, 4.0)
			canvas.draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), ink, 4.0)
		&"star":
			_draw_star(canvas, center, radius, ink)
		_:
			canvas.draw_circle(center, radius * 0.4, ink)


static func _draw_ngon(canvas: CanvasItem, center: Vector2, radius: float, sides: int, ink: Color) -> void:
	var points := PackedVector2Array()
	for k in sides:
		var angle := -PI / 2.0 + k * TAU / sides
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	canvas.draw_colored_polygon(points, ink)


static func _draw_star(canvas: CanvasItem, center: Vector2, radius: float, ink: Color) -> void:
	var points := PackedVector2Array()
	for k in 10:
		var r := radius if k % 2 == 0 else radius * 0.45
		var angle := -PI / 2.0 + k * PI / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	canvas.draw_colored_polygon(points, ink)

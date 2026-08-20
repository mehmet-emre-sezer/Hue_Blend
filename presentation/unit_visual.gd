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


const CORNER := 10.0

## Tek birim: boya blobu + (opsiyonel) sembol. Panellerde (tarif/koleksiyon/eser) kullanılır.
static func draw_unit(canvas: CanvasItem, rect: Rect2, color: Color, symbol_id: StringName, show_symbol: bool) -> void:
	draw_blob(canvas, rect, color)
	if show_symbol:
		draw_symbol(canvas, symbol_id, rect.get_center())


## Boya gövdesi: candy hissi — gövde + kenar + alt hacim gölgesi + üst gloss + parıltı.
## Tüplerde bir "sıvı sütunu" (aynı renk birleşik run) tek çağrıyla çizilebilsin diye ayrı.
static func draw_blob(canvas: CanvasItem, rect: Rect2, color: Color) -> void:
	# Gövde + candy kenar (tanım için hafif koyu çerçeve).
	var body := StyleBoxFlat.new()
	body.bg_color = color
	body.set_corner_radius_all(int(CORNER))
	body.set_border_width_all(2)
	body.border_color = color.darkened(0.24)
	body.anti_aliasing = true
	canvas.draw_style_box(body, rect)

	# Alt hacim gölgesi (altta yumuşak koyulaşma → hacim/derinlik).
	var shade := StyleBoxFlat.new()
	var shade_color := color.darkened(0.22)
	shade_color.a = 0.40
	shade.bg_color = shade_color
	shade.corner_radius_bottom_left = int(CORNER)
	shade.corner_radius_bottom_right = int(CORNER)
	var shade_h := rect.size.y * 0.30
	canvas.draw_style_box(shade, Rect2(rect.position + Vector2(0, rect.size.y - shade_h), Vector2(rect.size.x, shade_h)))

	# Üst gloss bandı (parlak, yuvarlak üst — şekerli seheni).
	var gloss := StyleBoxFlat.new()
	var gloss_color := color.lightened(0.42)
	gloss_color.a = 0.6
	gloss.bg_color = gloss_color
	gloss.corner_radius_top_left = int(CORNER)
	gloss.corner_radius_top_right = int(CORNER)
	gloss.corner_radius_bottom_left = int(CORNER * 0.6)
	gloss.corner_radius_bottom_right = int(CORNER * 0.6)
	var gloss_h := minf(rect.size.y * 0.40, 26.0)
	canvas.draw_style_box(gloss, Rect2(rect.position + Vector2(4, 4), Vector2(rect.size.x - 8, gloss_h)))

	# Specular parıltı (küçük beyaz nokta, sol-üst).
	canvas.draw_circle(rect.position + Vector2(rect.size.x * 0.30, 11.0), 4.5, Color(1, 1, 1, 0.55))


static func draw_symbol(canvas: CanvasItem, symbol_id: StringName, center: Vector2) -> void:
	_draw_symbol(canvas, symbol_id, center, SYMBOL_RADIUS)


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

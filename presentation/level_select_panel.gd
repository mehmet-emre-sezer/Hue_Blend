class_name LevelSelectPanel
extends Control

## Seviye seçim ekranı: numaralı tablo. Açık seviyeler seçilebilir, kilitliler gri.
## Açık bir seviyeye dokununca level_chosen yayılır; boşluğa/kilitliye dokununca kapanır.

signal level_chosen(index: int)

var _total := 0
var _unlocked := 0   # açık seviye sayısı (index 0.._unlocked-1 oynanabilir)
var _current := 0

const TILE := 62.0
const GAP := 12.0
const COLS := 4


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()


func show_levels(screen_size: Vector2, total: int, unlocked: int, current: int) -> void:
	size = screen_size
	position = Vector2.ZERO
	_total = total
	_unlocked = unlocked
	_current = current
	show()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var pressed: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if not pressed:
		return
	var tapped_position: Vector2 = event.position
	var index := _tile_at(tapped_position)
	if index >= 0 and index < _unlocked:
		hide()
		level_chosen.emit(index)
	else:
		hide()  # boşluk/kilitli → kapat


func _grid_origin() -> Vector2:
	var rows := int(ceil(float(_total) / COLS))
	var grid_width := COLS * TILE + (COLS - 1) * GAP
	var grid_height := rows * TILE + (rows - 1) * GAP
	return Vector2(size.x / 2.0 - grid_width / 2.0, size.y / 2.0 - grid_height / 2.0)


func _tile_at(point: Vector2) -> int:
	var origin := _grid_origin()
	for i in _total:
		var top_left := origin + Vector2((i % COLS) * (TILE + GAP), (i / COLS) * (TILE + GAP))
		if Rect2(top_left, Vector2(TILE, TILE)).has_point(point):
			return i
	return -1


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.82))
	var origin := _grid_origin()
	for i in _total:
		var top_left := origin + Vector2((i % COLS) * (TILE + GAP), (i / COLS) * (TILE + GAP))
		var rect := Rect2(top_left, Vector2(TILE, TILE))
		var unlocked := i < _unlocked

		var box := StyleBoxFlat.new()
		box.set_corner_radius_all(12)
		box.bg_color = Color(0.32, 0.30, 0.42) if unlocked else Color(1, 1, 1, 0.06)
		if i == _current:
			box.set_border_width_all(3)
			box.border_color = Color(1, 0.85, 0.4)
		draw_style_box(box, rect)

		var label := str(i + 1) if unlocked else "?"
		var ink := Color(1, 1, 1, 0.92) if unlocked else Color(1, 1, 1, 0.35)
		draw_string(
			ThemeDB.fallback_font, Vector2(rect.position.x, rect.get_center().y + 9),
			label, HORIZONTAL_ALIGNMENT_CENTER, TILE, 24, ink
		)

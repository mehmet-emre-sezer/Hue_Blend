class_name ArtworkPanel
extends Control

## "Eser" ekranı: çözülen seviyeler mozaiği doldurur. Açılan hücreler renkli,
## açılmamışlar gri placeholder. İlerledikçe desen (kalp) ortaya çıkar. Dokununca kapanır.

var _rows: Array = []
var _colors: ColorRegistry
var _fill_count := 0
var _show_symbols := false

const TILE := 46.0
const GAP := 6.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()


func show_artwork(screen_size: Vector2, rows: Array, colors: ColorRegistry, fill_count: int, show_symbols: bool) -> void:
	size = screen_size
	position = Vector2.ZERO
	_rows = rows
	_colors = colors
	_fill_count = fill_count
	_show_symbols = show_symbols
	show()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if tapped:
		hide()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.82))
	if _rows.is_empty():
		return

	var cols := 0
	for row in _rows:
		cols = max(cols, row.size())
	var grid_width := cols * TILE + (cols - 1) * GAP
	var grid_height := _rows.size() * TILE + (_rows.size() - 1) * GAP
	var start := Vector2(size.x / 2.0 - grid_width / 2.0, size.y / 2.0 - grid_height / 2.0)

	var picture_index := 0
	var total := 0
	for row in _rows:
		for id in row:
			if id != "":
				total += 1

	for r in _rows.size():
		var row: Array = _rows[r]
		for c in row.size():
			var id: String = row[c]
			if id == "":
				continue
			var top_left := start + Vector2(c * (TILE + GAP), r * (TILE + GAP))
			var rect := Rect2(top_left, Vector2(TILE, TILE))
			if picture_index < _fill_count:
				var card := _colors.get_card(StringName(id))
				UnitVisual.draw_unit(self, rect, card.display_color, card.symbol_id, _show_symbols)
			else:
				var placeholder := StyleBoxFlat.new()
				placeholder.bg_color = Color(1, 1, 1, 0.08)
				placeholder.set_corner_radius_all(8)
				draw_style_box(placeholder, rect)
			picture_index += 1

	# İlerleme sayacı
	var revealed: int = min(_fill_count, total)
	draw_string(
		ThemeDB.fallback_font, Vector2(start.x, start.y - 18),
		"%d / %d" % [revealed, total], HORIZONTAL_ALIGNMENT_CENTER, grid_width, 26, Color(1, 1, 1, 0.85)
	)

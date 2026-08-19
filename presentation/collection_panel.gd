class_name CollectionPanel
extends Control

## Koleksiyon ekranı: keşfedilmiş renkler dolu, keşfedilmemişler kilitli (gri + "?").
## Dilden bağımsız. Dokununca kapanır.

var _entries: Array = []  # [{card: ColorCard, discovered: bool}]
var _show_symbols := false

const SWATCH := 74.0
const GAP := 22.0
const COLS := 3


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()


func show_collection(screen_size: Vector2, entries: Array, show_symbols: bool) -> void:
	size = screen_size
	position = Vector2.ZERO
	_entries = entries
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
	var rows := int(ceil(float(_entries.size()) / COLS))
	var grid_width := COLS * SWATCH + (COLS - 1) * GAP
	var grid_height := rows * SWATCH + (rows - 1) * GAP
	var start := Vector2(size.x / 2.0 - grid_width / 2.0, size.y / 2.0 - grid_height / 2.0)
	for i in _entries.size():
		var col := i % COLS
		var row := i / COLS
		var top_left := start + Vector2(col * (SWATCH + GAP), row * (SWATCH + GAP))
		_draw_entry(_entries[i], top_left)


func _draw_entry(entry: Dictionary, top_left: Vector2) -> void:
	var rect := Rect2(top_left, Vector2(SWATCH, SWATCH))
	if entry.discovered:
		UnitVisual.draw_unit(self, rect, entry.card.display_color, entry.card.symbol_id, _show_symbols)
	else:
		draw_rect(rect, Color(0.24, 0.24, 0.28))  # kilitli
		draw_string(
			ThemeDB.fallback_font, Vector2(rect.position.x, rect.get_center().y + 14),
			"?", HORIZONTAL_ALIGNMENT_CENTER, SWATCH, 40, Color(1, 1, 1, 0.5)
		)

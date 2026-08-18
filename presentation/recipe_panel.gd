class_name RecipePanel
extends Control

## Tarif/info ekranı (dilden bağımsız — metin yok): bu bölümde geçerli karışım tarifleri.
## Her satır: [renk A] + [renk B] = [ikincil]. Dokununca kapanır.

var _recipes: Array = []  # [{a: ColorCard, b: ColorCard, result: ColorCard}]
var _show_symbols := false

const SWATCH := 54.0
const GAP := 40.0
const ROW_GAP := 34.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()


func show_recipes(screen_size: Vector2, recipes: Array, show_symbols: bool) -> void:
	size = screen_size
	position = Vector2.ZERO
	_recipes = recipes
	_show_symbols = show_symbols
	show()
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if tapped:
		hide()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.7))
	var row_height := SWATCH + ROW_GAP
	var total_height := _recipes.size() * row_height
	var y := size.y / 2.0 - total_height / 2.0 + SWATCH / 2.0
	for recipe in _recipes:
		_draw_row(recipe, size.x / 2.0, y)
		y += row_height


func _draw_row(recipe: Dictionary, cx: float, cy: float) -> void:
	var total_width := 3.0 * SWATCH + 2.0 * GAP
	var x0 := cx - total_width / 2.0
	var half := SWATCH / 2.0
	_draw_swatch(recipe.a, Vector2(x0, cy - half))
	_draw_swatch(recipe.b, Vector2(x0 + SWATCH + GAP, cy - half))
	_draw_swatch(recipe.result, Vector2(x0 + 2.0 * (SWATCH + GAP), cy - half))
	_draw_plus(Vector2(x0 + SWATCH + GAP / 2.0, cy))
	_draw_equals(Vector2(x0 + 2.0 * SWATCH + GAP + GAP / 2.0, cy))


func _draw_swatch(card: ColorCard, top_left: Vector2) -> void:
	UnitVisual.draw_unit(self, Rect2(top_left, Vector2(SWATCH, SWATCH)), card.display_color, card.symbol_id, _show_symbols)


func _draw_plus(center: Vector2) -> void:
	var s := 10.0
	var ink := Color(1, 1, 1, 0.85)
	draw_line(center + Vector2(-s, 0), center + Vector2(s, 0), ink, 3.0)
	draw_line(center + Vector2(0, -s), center + Vector2(0, s), ink, 3.0)


func _draw_equals(center: Vector2) -> void:
	var s := 10.0
	var ink := Color(1, 1, 1, 0.85)
	draw_line(center + Vector2(-s, -4), center + Vector2(s, -4), ink, 3.0)
	draw_line(center + Vector2(-s, 4), center + Vector2(s, 4), ink, 3.0)

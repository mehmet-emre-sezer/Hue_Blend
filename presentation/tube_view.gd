class_name TubeView
extends Node2D

## Tek tüpün görseli (placeholder — kodla çizilir). Çekirdeği OKUR, mantık içermez.
## Birim çizimi UnitVisual'den gelir (renk + erişilebilirlik sembolü). Origin: sol-üst.

var _tube: Tube
var _selected := false
var _flash := 0.0  # tamamlanma parlaması (0→görünmez)
var _show_symbols := false  # renk körü sembolleri (ayara bağlı)


func setup(tube: Tube, show_symbols: bool) -> void:
	_tube = tube
	_show_symbols = show_symbols
	queue_redraw()


func set_show_symbols(value: bool) -> void:
	if _show_symbols == value:
		return
	_show_symbols = value
	queue_redraw()


func set_selected(value: bool) -> void:
	if _selected == value:
		return
	_selected = value
	queue_redraw()


## Tüp tamamlandığında kısa bir parlama (küçük zafer geri bildirimi).
func play_complete_pulse() -> void:
	_flash = 0.55
	queue_redraw()
	create_tween().tween_method(_set_flash, _flash, 0.0, 0.45).set_ease(Tween.EASE_OUT)


## Geçersiz hamlede kısa yatay titreme (hedef kabul etmiyor geri bildirimi).
func play_invalid_shake() -> void:
	var base_x := position.x
	var tween := create_tween()
	tween.tween_property(self, "position:x", base_x - 7.0, 0.04)
	tween.tween_property(self, "position:x", base_x + 7.0, 0.04)
	tween.tween_property(self, "position:x", base_x, 0.04)


func _set_flash(value: float) -> void:
	_flash = value
	queue_redraw()


func tube_size() -> Vector2:
	var capacity := _tube.capacity() if _tube != null else 0
	return Vector2(UnitVisual.TUBE_WIDTH, capacity * UnitVisual.UNIT_HEIGHT)


## Yerel koordinatta bir nokta bu tüpün sınırları içinde mi (dokunuş isabeti için).
func contains_local(local_point: Vector2) -> bool:
	return Rect2(Vector2.ZERO, tube_size()).has_point(local_point)


## Bir slotun (0=dip) global merkez noktası — dökme animasyonu için.
func slot_world_center(slot_index: int) -> Vector2:
	var height := _tube.capacity() * UnitVisual.UNIT_HEIGHT
	var local := Vector2(UnitVisual.TUBE_WIDTH / 2.0, height - (slot_index + 0.5) * UnitVisual.UNIT_HEIGHT)
	return to_global(local)


func _draw() -> void:
	if _tube == null:
		return
	var height := _tube.capacity() * UnitVisual.UNIT_HEIGHT
	var bounds := Rect2(0, 0, UnitVisual.TUBE_WIDTH, height)

	# Cam kavanoz gövde (yuvarlak, hafif saydam)
	var glass := StyleBoxFlat.new()
	glass.bg_color = Color(1, 1, 1, 0.05)
	glass.set_corner_radius_all(14)
	glass.corner_radius_top_left = 8
	glass.corner_radius_top_right = 8
	draw_style_box(glass, bounds)

	var cards := _tube.cards_snapshot()  # dip→üst
	var top_index := cards.size() - 1
	for i in cards.size():
		var card: ColorCard = cards[i]
		var y := height - (i + 1) * UnitVisual.UNIT_HEIGHT
		var lift := -10.0 if (_selected and i == top_index) else 0.0  # seçili üst birim yükselir
		var rect := Rect2(
			UnitVisual.PADDING, y + UnitVisual.PADDING + lift,
			UnitVisual.TUBE_WIDTH - 2 * UnitVisual.PADDING,
			UnitVisual.UNIT_HEIGHT - 2 * UnitVisual.PADDING
		)
		UnitVisual.draw_unit(self, rect, card.display_color, card.symbol_id, _show_symbols)

	# Cam parlaması (sol dikey şerit)
	draw_line(Vector2(7, 12), Vector2(7, height - 14), Color(1, 1, 1, 0.10), 3.0)

	if _flash > 0.0:
		var flash_box := StyleBoxFlat.new()
		flash_box.bg_color = Color(1, 1, 1, _flash)
		flash_box.set_corner_radius_all(14)
		draw_style_box(flash_box, bounds)  # tamamlanma parlaması

	# Yuvarlak dış çizgi (seçiliyse vurgulu)
	var outline := StyleBoxFlat.new()
	outline.draw_center = false
	outline.set_corner_radius_all(14)
	outline.corner_radius_top_left = 8
	outline.corner_radius_top_right = 8
	outline.set_border_width_all(4 if _selected else 2)
	outline.border_color = Color(1, 0.85, 0.4) if _selected else Color(1, 1, 1, 0.45)
	draw_style_box(outline, bounds)

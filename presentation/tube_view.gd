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


## Aynı renk bitişik birimleri gruplar: [{color, start, count}] (dip→üst).
func _runs(cards: Array) -> Array:
	var runs: Array = []
	var i := 0
	while i < cards.size():
		var color: ColorCard = cards[i]
		var j := i
		while j < cards.size() and cards[j].same_as(color):
			j += 1
		runs.append({"color": color, "start": i, "count": j - i})
		i = j
	return runs


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

	# Aynı renk bitişik birimler TEK sıvı sütunu olarak çizilir (kutu değil, boya hissi).
	var cards := _tube.cards_snapshot()  # dip→üst
	var runs := _runs(cards)
	var last_run := runs.size() - 1
	for r in runs.size():
		var run: Dictionary = runs[r]
		var start := int(run.start)
		var count := int(run.count)
		var run_color: ColorCard = run.color
		var lift := -10.0 if (_selected and r == last_run) else 0.0  # seçili üst sıvı yükselir
		var run_top := height - (start + count) * UnitVisual.UNIT_HEIGHT
		var rect := Rect2(
			UnitVisual.PADDING, run_top + 2.0 + lift,
			UnitVisual.TUBE_WIDTH - 2 * UnitVisual.PADDING,
			count * UnitVisual.UNIT_HEIGHT - 4.0
		)
		UnitVisual.draw_blob(self, rect, run_color.display_color)
		# Aynı renk birimler arası ince ayraç: miktar sayılabilsin (karışımda önemli),
		# ama tek sıvı sütunu/boya hissi korunsun (kutu boşluğu değil, boya seheni).
		if count > 1:
			var seam := run_color.display_color.darkened(0.22)
			seam.a = 0.35
			for k in range(1, count):
				var seam_y := run_top + lift + k * UnitVisual.UNIT_HEIGHT
				draw_line(
					Vector2(rect.position.x + 3.0, seam_y),
					Vector2(rect.position.x + rect.size.x - 3.0, seam_y),
					seam, 2.0
				)
		if _show_symbols:
			for k in count:
				var symbol_y := height - (start + k + 0.5) * UnitVisual.UNIT_HEIGHT + lift
				UnitVisual.draw_symbol(self, run_color.symbol_id, Vector2(UnitVisual.TUBE_WIDTH / 2.0, symbol_y))

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

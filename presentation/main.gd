extends Node2D

## Faz 1 oynanış denetleyicisi: içerik+ilerlemeyi kurar, tahtayı gösterir, dokunuşu hamleye
## çevirir, geri-al ve kazanç/ilerleme akışını yönetir. Çekirdek ↔ sunum köprüsü (TDD §K1).

const POUR_DURATION := 0.20
const POUR_STAGGER := 0.05  # birimler sıra sıra aksın
const ARC_HEIGHT := 70.0    # ağızdan dökülme kavisi yüksekliği
const MIX_HOLD := 0.32      # karışımdan önce "dökülen renk hedef üstünde" görünür kalsın

var _colors: ColorRegistry
var _full_rules: MixRules       # tüm karışım kataloğu
var _current_rules: MixRules    # bu seviyenin açık tarifleri (seviye-bazlı sınırlama)
var _levels: Array[LevelData]
var _level_index: int = 0
var _save: SaveService
var _settings: Settings

var _board: Board
var _history: MoveHistory
var _board_view: BoardView
var _win_overlay: WinOverlay
var _recipe_panel: RecipePanel
var _info_button: Button
var _selected_tube: int = -1
var _animating := false


func _ready() -> void:
	_colors = GameContent.colors()
	_full_rules = GameContent.mix_rules(_colors)
	_levels = GameContent.levels()
	_save = SaveService.new()
	_settings = Settings.new()
	_level_index = clampi(_save.load_level_index(), 0, _levels.size() - 1)
	_build_ui()
	_start_level()


func _build_ui() -> void:
	add_child(DebugOverlay.new())

	var ui := CanvasLayer.new()
	add_child(ui)

	var undo_button := Button.new()
	undo_button.text = "↺"
	undo_button.add_theme_font_size_override("font_size", 36)
	undo_button.custom_minimum_size = Vector2(72, 72)
	undo_button.position = Vector2(20, get_viewport_rect().size.y - 92)
	undo_button.pressed.connect(_on_undo_pressed)
	ui.add_child(undo_button)

	# Ayar toggle'ları (placeholder — Faz 3 ayar ekranında ikonlaşacak).
	var right := get_viewport_rect().size.x - 150

	var motion_toggle := CheckButton.new()
	motion_toggle.button_pressed = _settings.reduced_motion
	motion_toggle.position = Vector2(right, 40)
	motion_toggle.toggled.connect(_on_reduced_motion_toggled)
	ui.add_child(motion_toggle)

	var colorblind_toggle := CheckButton.new()
	colorblind_toggle.button_pressed = _settings.colorblind_mode
	colorblind_toggle.position = Vector2(right, 100)
	colorblind_toggle.toggled.connect(_on_colorblind_toggled)
	ui.add_child(colorblind_toggle)

	# Tarif/info düğmesi (yalnız karışım seviyelerinde görünür).
	_info_button = Button.new()
	_info_button.text = "?"
	_info_button.add_theme_font_size_override("font_size", 34)
	_info_button.custom_minimum_size = Vector2(64, 64)
	_info_button.position = Vector2(get_viewport_rect().size.x / 2.0 - 32, 36)
	_info_button.pressed.connect(_on_info_pressed)
	ui.add_child(_info_button)

	_win_overlay = WinOverlay.new()
	_win_overlay.continue_requested.connect(_on_continue)
	ui.add_child(_win_overlay)

	_recipe_panel = RecipePanel.new()
	ui.add_child(_recipe_panel)


func _on_info_pressed() -> void:
	_recipe_panel.show_recipes(get_viewport_rect().size, _recipes_display(), _settings.colorblind_mode)


## Bu seviyenin açık tariflerini (zincir dahil) kutucuk verisine çevirir.
func _recipes_display() -> Array:
	var out: Array = []
	if _current_rules == null:
		return out
	for recipe in _current_rules.recipes():
		out.append({
			"a": _colors.get_card(recipe.a),
			"b": _colors.get_card(recipe.b),
			"result": recipe.result,
		})
	return out


## Seviyenin AÇIK tariflerinden sınırlı MixRules (null → karışım yok).
func _rules_for_level(level: LevelData) -> MixRules:
	if not level.uses_mixing:
		return null
	var scoped := MixRules.new()
	for pair in level.mix_pairs:
		var a := StringName(pair[0])
		var b := StringName(pair[1])
		var result := _full_rules.result_of(a, b)
		if result != null:
			scoped.add(a, b, result)
	return scoped


func _on_reduced_motion_toggled(pressed: bool) -> void:
	_settings.set_reduced_motion(pressed)


func _on_colorblind_toggled(pressed: bool) -> void:
	_settings.set_colorblind_mode(pressed)
	_board_view.set_show_symbols(pressed)


func _start_level() -> void:
	if _board_view != null:
		_board_view.queue_free()

	var level := _levels[_level_index]
	_current_rules = _rules_for_level(level)
	var errors := LevelValidator.new().validate(level, _colors, _current_rules)
	assert(errors.is_empty(), "seviye geçersiz: %s" % ", ".join(errors))

	_board = LevelLoader.new().load_board(level, _colors, _current_rules)
	_history = MoveHistory.new(_board)

	_board_view = BoardView.new()
	add_child(_board_view)
	_board_view.setup(_board, _settings.colorblind_mode)
	var viewport_size := get_viewport_rect().size
	_board_view.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.45)

	_set_selection(-1)
	_win_overlay.hide()
	_recipe_panel.hide()
	_info_button.visible = level.uses_mixing  # tarif düğmesi yalnız karışım seviyelerinde


func _on_continue() -> void:
	# Kazançtan sonra bir sonraki seviyeye geç (son seviyedeyse tekrar oyna) ve kaydet.
	if _level_index < _levels.size() - 1:
		_level_index += 1
		_save.save_progress(_level_index)
	_start_level()


func _unhandled_input(event: InputEvent) -> void:
	# DEBUG: N/P ile seviye atla (yayından önce kaldırılacak — X-028).
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_N:
			_debug_jump_level(1)
			return
		if event.keycode == KEY_P:
			_debug_jump_level(-1)
			return
	if event is InputEventScreenTouch and event.pressed:
		_on_tap(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_tap(event.position)


func _debug_jump_level(delta: int) -> void:
	if _animating:
		return
	_level_index = clampi(_level_index + delta, 0, _levels.size() - 1)
	_start_level()


func _on_tap(screen_position: Vector2) -> void:
	if _animating:
		return
	var index := _board_view.tube_index_at(screen_position)
	if index == -1:
		_set_selection(-1)  # boşluğa dokunma → iptal
		return
	if _selected_tube == -1:
		_set_selection(index)  # ilk dokunuş → kaynağı seç
		return
	if index == _selected_tube:
		_set_selection(-1)  # aynı tüp → iptal
		return
	_try_move(_selected_tube, index)
	_set_selection(-1)


func _try_move(from_index: int, to_index: int) -> void:
	var move := _board.build_move(from_index, to_index)
	if move == null:
		_board_view.tube_view(from_index).play_invalid_shake()  # geçersiz → titre
		return

	# Görsel bilgiyi hamleyi UYGULAMADAN önce yakala.
	var count := move.moved_count()
	var color := _board.tube(from_index).top()
	var source_size := _board.tube(from_index).size()
	var dest_size := _board.tube(to_index).size()

	var result := _history.apply(move)
	var flash := result.dest_tube_solved or result.mixed  # tamamlanma ya da karışım → parla
	_animate_transfer(from_index, to_index, source_size, dest_size, count, color, result.board_solved, flash, result.mixed)


func _on_undo_pressed() -> void:
	if _animating or not _history.can_undo():
		return
	_set_selection(-1)
	_win_overlay.hide()
	# Son hamle from→to idi; geri alma to→from yönünde akar.
	var move := _history.peek()
	var count := move.moved_count()
	var color := move.color()
	var source_size := _board.tube(move.to_index()).size()
	var dest_size := _board.tube(move.from_index()).size()
	_history.undo_last()
	_animate_transfer(move.to_index(), move.from_index(), source_size, dest_size, count, color, false, false, false)


## Birimleri kaynak tüpün üstünden hedefe kavis çizerek akıtır (dökülme hissi).
## Model çağıran tarafından zaten güncellendi; burada yalnız görsel + girdi kilidi.
func _animate_transfer(
	source_index: int, dest_index: int,
	source_size_before: int, dest_size_before: int,
	count: int, color: ColorCard, won: bool, should_flash: bool, mixed: bool
) -> void:
	var source_view := _board_view.tube_view(source_index)
	var dest_view := _board_view.tube_view(dest_index)
	_board_view.refresh_tube(source_index)  # birimler kaynaktan ayrılır

	if _settings.reduced_motion:
		_finish_transfer(dest_index, won, should_flash)  # animasyonsuz anında güncelle
		return

	_animating = true
	var flyers := Node2D.new()
	add_child(flyers)
	var tween := create_tween().set_parallel(true)
	for k in count:
		var start_point := source_view.slot_world_center(source_size_before - 1 - k)
		var end_point := dest_view.slot_world_center(dest_size_before + count - 1 - k)
		var flyer := FlyingUnit.new()
		flyer.setup(color.display_color, color.symbol_id, _settings.colorblind_mode)
		flyer.global_position = start_point
		flyers.add_child(flyer)
		tween.tween_method(
			_arc_position.bind(flyer, start_point, end_point), 0.0, 1.0, POUR_DURATION
		).set_delay(k * POUR_STAGGER)
	tween.chain()
	if mixed:
		# Dökülen renk hedefin üstünde bir an dursun → oyuncu "ne ile karıştığını" görsün.
		tween.tween_interval(MIX_HOLD)
	tween.tween_callback(_on_transfer_done.bind(flyers, dest_index, won, should_flash))


## t=0→1 boyunca doğrusal ilerleme + ortada zirve yapan dikey kavis (ağızdan dökülme).
func _arc_position(t: float, flyer: FlyingUnit, start_point: Vector2, end_point: Vector2) -> void:
	var lift := ARC_HEIGHT * sin(t * PI)
	flyer.global_position = start_point.lerp(end_point, t) - Vector2(0, lift)


func _on_transfer_done(flyers: Node2D, dest_index: int, won: bool, should_flash: bool) -> void:
	flyers.queue_free()
	_animating = false
	_finish_transfer(dest_index, won, should_flash)


## Hamlenin görsel sonucu: hedefi tazele, tamamlandıysa parla, kazanıldıysa ekranı göster.
## Hem animasyonlu hem reduced-motion yolu buraya varır.
func _finish_transfer(dest_index: int, won: bool, should_flash: bool) -> void:
	_board_view.refresh_tube(dest_index)  # birimler hedefte belirir
	if should_flash and not _settings.reduced_motion:
		_board_view.tube_view(dest_index).play_complete_pulse()  # küçük zafer
	if won:
		_win_overlay.show_win(get_viewport_rect().size)


func _set_selection(index: int) -> void:
	_selected_tube = index
	_board_view.set_selected(index)

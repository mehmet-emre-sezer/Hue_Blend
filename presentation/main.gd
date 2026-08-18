extends Node2D

## Faz 1 oynanış denetleyicisi: seviyeyi kurar, tahtayı gösterir, dokunuşu hamleye çevirir,
## geri-al ve kazanç ekranını yönetir. Çekirdek ↔ sunum köprüsü (TDD §K1).
## Not: dökme animasyonu ve ses sonraki adımlarda; şimdilik anında güncelleme.

const POUR_DURATION := 0.16

var _board: Board
var _history: MoveHistory
var _board_view: BoardView
var _win_overlay: WinOverlay
var _selected_tube: int = -1
var _animating := false


func _ready() -> void:
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

	_win_overlay = WinOverlay.new()
	_win_overlay.restart_requested.connect(_start_level)
	ui.add_child(_win_overlay)


func _start_level() -> void:
	if _board_view != null:
		_board_view.queue_free()

	var colors := GameContent.colors()
	var level := GameContent.level_one()
	var errors := LevelValidator.new().validate(level, colors)
	assert(errors.is_empty(), "seviye geçersiz: %s" % ", ".join(errors))

	_board = LevelLoader.new().load_board(level, colors)
	_history = MoveHistory.new(_board)

	_board_view = BoardView.new()
	add_child(_board_view)
	_board_view.setup(_board)
	var viewport_size := get_viewport_rect().size
	_board_view.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.45)

	_set_selection(-1)
	_win_overlay.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_on_tap(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_tap(event.position)


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
		return  # geçersiz hamle → sessizce yok say (geri bildirim sonra)

	# Görsel başlangıç/bitiş noktalarını hamleyi UYGULAMADAN önce yakala.
	var count := move.moved_count()
	var top_card := _board.tube(from_index).top()
	var from_size := _board.tube(from_index).size()
	var to_size := _board.tube(to_index).size()
	var from_view := _board_view.tube_view(from_index)
	var to_view := _board_view.tube_view(to_index)

	var starts: Array[Vector2] = []
	var ends: Array[Vector2] = []
	for k in count:
		starts.append(from_view.slot_world_center(from_size - 1 - k))
		ends.append(to_view.slot_world_center(to_size + count - 1 - k))

	# Modeli güncelle, kaynağı hemen tazele (birimler kaynaktan ayrılır).
	var result := _history.apply(move)
	_board_view.refresh_tube(from_index)

	_animating = true
	var flyers := Node2D.new()
	add_child(flyers)
	var tween := create_tween().set_parallel(true)
	for k in count:
		var flyer := FlyingUnit.new()
		flyer.setup(top_card.display_color, top_card.symbol_id)
		flyer.global_position = starts[k]
		flyers.add_child(flyer)
		tween.tween_property(flyer, "global_position", ends[k], POUR_DURATION) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(_on_pour_done.bind(flyers, to_index, result))


func _on_pour_done(flyers: Node2D, to_index: int, result: MoveResult) -> void:
	flyers.queue_free()
	_board_view.refresh_tube(to_index)  # birimler hedefte belirir
	_animating = false
	if result.board_solved:
		_win_overlay.show_win(get_viewport_rect().size)


func _on_undo_pressed() -> void:
	if _animating or not _history.can_undo():
		return
	_history.undo_last()
	_board_view.refresh_all()
	_set_selection(-1)
	_win_overlay.hide()


func _set_selection(index: int) -> void:
	_selected_tube = index
	_board_view.set_selected(index)

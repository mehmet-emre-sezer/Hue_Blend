extends Node2D

## Faz 1 oynanış denetleyicisi: seviyeyi kurar, tahtayı gösterir, dokunuşu hamleye çevirir,
## geri-al ve kazanç ekranını yönetir. Çekirdek ↔ sunum köprüsü (TDD §K1).
## Not: dökme animasyonu ve ses sonraki adımlarda; şimdilik anında güncelleme.

var _board: Board
var _history: MoveHistory
var _board_view: BoardView
var _win_overlay: WinOverlay
var _selected_tube: int = -1


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
	var result := _history.apply(move)
	_board_view.refresh_tube(from_index)
	_board_view.refresh_tube(to_index)
	if result.board_solved:
		_win_overlay.show_win(get_viewport_rect().size)


func _on_undo_pressed() -> void:
	if not _history.can_undo():
		return
	_history.undo_last()
	_board_view.refresh_all()
	_set_selection(-1)
	_win_overlay.hide()


func _set_selection(index: int) -> void:
	_selected_tube = index
	_board_view.set_selected(index)

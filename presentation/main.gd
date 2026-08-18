extends Node2D

## Faz 1 oynanış denetleyicisi: seviyeyi kurar, tahtayı gösterir, dokunuşu hamleye çevirir,
## geri-al ve kazanç ekranını yönetir. Çekirdek ↔ sunum köprüsü (TDD §K1).
## Not: dökme animasyonu ve ses sonraki adımlarda; şimdilik anında güncelleme.

const POUR_DURATION := 0.20
const POUR_STAGGER := 0.05  # birimler sıra sıra aksın
const ARC_HEIGHT := 70.0    # ağızdan dökülme kavisi yüksekliği

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

	# Görsel bilgiyi hamleyi UYGULAMADAN önce yakala.
	var count := move.moved_count()
	var color := _board.tube(from_index).top()
	var source_size := _board.tube(from_index).size()
	var dest_size := _board.tube(to_index).size()

	var result := _history.apply(move)
	_animate_transfer(from_index, to_index, source_size, dest_size, count, color, result.board_solved)


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
	_animate_transfer(move.to_index(), move.from_index(), source_size, dest_size, count, color, false)


## Birimleri kaynak tüpün üstünden hedefe kavis çizerek akıtır (dökülme hissi).
## Model çağıran tarafından zaten güncellendi; burada yalnız görsel + girdi kilidi.
func _animate_transfer(
	source_index: int, dest_index: int,
	source_size_before: int, dest_size_before: int,
	count: int, color: ColorCard, won: bool
) -> void:
	var source_view := _board_view.tube_view(source_index)
	var dest_view := _board_view.tube_view(dest_index)
	_board_view.refresh_tube(source_index)  # birimler kaynaktan ayrılır

	_animating = true
	var flyers := Node2D.new()
	add_child(flyers)
	var tween := create_tween().set_parallel(true)
	for k in count:
		var start_point := source_view.slot_world_center(source_size_before - 1 - k)
		var end_point := dest_view.slot_world_center(dest_size_before + count - 1 - k)
		var flyer := FlyingUnit.new()
		flyer.setup(color.display_color, color.symbol_id)
		flyer.global_position = start_point
		flyers.add_child(flyer)
		tween.tween_method(
			_arc_position.bind(flyer, start_point, end_point), 0.0, 1.0, POUR_DURATION
		).set_delay(k * POUR_STAGGER)
	tween.chain().tween_callback(_on_transfer_done.bind(flyers, dest_index, won))


## t=0→1 boyunca doğrusal ilerleme + ortada zirve yapan dikey kavis (ağızdan dökülme).
func _arc_position(t: float, flyer: FlyingUnit, start_point: Vector2, end_point: Vector2) -> void:
	var lift := ARC_HEIGHT * sin(t * PI)
	flyer.global_position = start_point.lerp(end_point, t) - Vector2(0, lift)


func _on_transfer_done(flyers: Node2D, dest_index: int, won: bool) -> void:
	flyers.queue_free()
	_board_view.refresh_tube(dest_index)  # birimler hedefte belirir
	_animating = false
	if won:
		_win_overlay.show_win(get_viewport_rect().size)


func _set_selection(index: int) -> void:
	_selected_tube = index
	_board_view.set_selected(index)

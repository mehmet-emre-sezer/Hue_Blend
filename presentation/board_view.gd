class_name BoardView
extends Node2D

## Tahtanın görseli: her tüp için bir TubeView oluşturur ve satırda ortalar.
## Konumlandırmayı KOD yapar (PRD "prosedürel çizilir" kararı) — elle xy yok.

const TUBE_SPACING := 22.0

var _tube_views: Array[TubeView] = []


func setup(board: Board) -> void:
	_clear()
	var count := board.tube_count()
	var total_width := count * TubeView.TUBE_WIDTH + (count - 1) * TUBE_SPACING
	var x := -total_width / 2.0  # BoardView origin'ine göre ortalı

	for i in count:
		var view := TubeView.new()
		add_child(view)
		view.setup(board.tube(i))
		view.position = Vector2(x, 0)
		_tube_views.append(view)
		x += TubeView.TUBE_WIDTH + TUBE_SPACING


## Verilen global noktanın hangi tüpe denk geldiği; hiçbiri değilse -1 (dokunuş için).
func tube_index_at(global_point: Vector2) -> int:
	for i in _tube_views.size():
		var view := _tube_views[i]
		if view.contains_local(view.to_local(global_point)):
			return i
	return -1


## Yalnızca verilen tüpü seçili gösterir (-1 = seçim yok).
func set_selected(index: int) -> void:
	for i in _tube_views.size():
		_tube_views[i].set_selected(i == index)


## Belirli bir tüpü yeniden çizer (hamle sonrası).
func refresh_tube(index: int) -> void:
	_tube_views[index].queue_redraw()


func refresh_all() -> void:
	for view in _tube_views:
		view.queue_redraw()


func _clear() -> void:
	for view in _tube_views:
		view.queue_free()
	_tube_views.clear()

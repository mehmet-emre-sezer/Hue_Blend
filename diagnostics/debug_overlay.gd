class_name DebugOverlay
extends CanvasLayer

## Hafif geliştirme göstergesi: FPS (GEA-034, IPROF). Shipping'de kapatılabilir.
## Simülasyon durumunu DEĞİŞTİRMEZ (DDRAW-004).

var _label: Label


func _ready() -> void:
	layer = 100
	_label = Label.new()
	_label.position = Vector2(12, 8)
	add_child(_label)


func _process(_delta: float) -> void:
	_label.text = "FPS %d" % Engine.get_frames_per_second()

class_name TitleScreen
extends Control

## Açılış ekranı: boya-paleti logosu + oyun adı + "Oyna" düğmesi. Dilden bağımsız (ikon).
## Oyna'ya basınca play_requested yayılır ve ekran gizlenir; oyun altta hazır bekler.
## Panel deseni (win_overlay/level_select gibi) — ayrı sahne/FSM yerine üstte duran katman.

signal play_requested

const _TITLE := "Karışım"
const _PALETTE := [
	Color("e0645a"),  # kırmızımsı
	Color("f2b134"),  # sarı
	Color("4a8fe0"),  # mavi
	Color("5ab463"),  # yeşil
	Color("9b5ac0"),  # mor
	Color("e08a3c"),  # turuncu
]

var _play_button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # altındaki tahtaya dokunuş sızmasın

	_play_button = Button.new()
	_play_button.text = "▶"
	_play_button.add_theme_font_size_override("font_size", 44)
	_play_button.custom_minimum_size = Vector2(128, 96)
	_play_button.add_theme_color_override("font_color", Color("2b2540"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("e0a34a")
	normal.set_corner_radius_all(48)
	_play_button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("edb45f")
	_play_button.add_theme_stylebox_override("hover", hover)
	_play_button.add_theme_stylebox_override("pressed", hover)

	_play_button.pressed.connect(_on_play_button)
	add_child(_play_button)
	hide()


func show_title(screen_size: Vector2) -> void:
	size = screen_size
	position = Vector2.ZERO
	_play_button.position = Vector2(size.x / 2.0 - 64.0, size.y * 0.62)
	show()
	queue_redraw()


func _on_play_button() -> void:
	play_requested.emit()


func _draw() -> void:
	# Opak cozy arka plan (oyun sahnesini örter — açılışta yalnız bu görünür).
	draw_rect(Rect2(Vector2.ZERO, size), Color("1d1830"))

	# Boya-paleti logosu: yumuşak bir yay boyunca örtüşen boya damlaları (karışım hissi).
	var center := Vector2(size.x / 2.0, size.y * 0.34)
	var spread := 118.0
	var last := _PALETTE.size() - 1
	for i in _PALETTE.size():
		var t := float(i) / last - 0.5  # -0.5 .. 0.5
		var dab := center + Vector2(t * 2.0 * spread, abs(t) * 40.0)
		_draw_dab(dab, 46.0, _PALETTE[i])

	# Oyun adı (wordmark) — logonun altında, ortalı.
	var font := ThemeDB.fallback_font
	var title_size := 72
	var text_width := font.get_string_size(_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	draw_string(
		font, Vector2(size.x / 2.0 - text_width / 2.0, size.y * 0.50),
		_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, Color("f2ead9")
	)


## Tek boya damlası: gövde + sol-üst parlaklık (cozy boya hissi, UnitVisual ile aynı dil).
func _draw_dab(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center, radius, color)
	var gloss := color.lightened(0.35)
	gloss.a = 0.5
	draw_circle(center - Vector2(radius * 0.28, radius * 0.30), radius * 0.42, gloss)

class_name TitleScreen
extends Control

## Ana sayfa: SICAK-AÇIK ATÖLYE zemini + boya-paleti logosu + oyun adı +
## "kaldığın seviye" göstergesi + kil OYNA butonu. Dilden bağımsız (ikon + sayı).
## Görsel sistem UITheme'den gelir (renk/gölge/köşe tek kaynak).
## Panel deseni — ayrı sahne/FSM yerine üstte duran katman; Oyna → play_requested, gizlenir.

signal play_requested

const _TITLE := "Karışım"
# Atölye paleti: sıcak zeminde parlayan boya damlaları (karışım motifi).
const _PALETTE := [
	Color("e0645a"),  # kırmızı
	Color("e0925a"),  # turuncu
	Color("e0c24a"),  # sarı
	Color("5ac06a"),  # yeşil
	Color("5a7ae0"),  # mavi
	Color("9b5ac0"),  # mor
]

const _PLAY_ICON := preload("res://assets/icons/play.svg")

var _play_button: Button
var _bg: GradientTexture2D
var _font_title: FontVariation
var _font_num: FontVariation
var _current := 1
var _total := 1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # altındaki oyun ekranına dokunuş sızmasın

	_font_title = UITheme.font_weight(600)
	_font_num = UITheme.font_weight(600)

	_bg = GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, UITheme.BG_TOP)
	gradient.set_color(1, UITheme.BG_BOTTOM)
	_bg.gradient = gradient
	_bg.fill_from = Vector2(0.5, 0.0)
	_bg.fill_to = Vector2(0.5, 1.0)
	_bg.width = 8
	_bg.height = 256

	_play_button = Button.new()
	_play_button.icon = _PLAY_ICON
	_play_button.expand_icon = true       # ikon buton içinde büyür (oran korunur)
	_play_button.custom_minimum_size = Vector2(150, 104)
	UITheme.style_clay_button(_play_button, UITheme.CLAY, UITheme.CLAY_INK, 46)
	_play_button.add_theme_color_override("icon_normal_color", UITheme.CLAY_INK)
	_play_button.add_theme_color_override("icon_hover_color", UITheme.CLAY_INK)
	_play_button.add_theme_color_override("icon_pressed_color", UITheme.CLAY_INK)
	_play_button.pressed.connect(_on_play_button)
	add_child(_play_button)
	hide()


func show_title(screen_size: Vector2, current_level: int, total_levels: int) -> void:
	size = screen_size
	position = Vector2.ZERO
	_current = current_level
	_total = total_levels
	_play_button.position = Vector2(size.x / 2.0 - 75.0, size.y * 0.67)
	show()
	queue_redraw()


func _on_play_button() -> void:
	play_requested.emit()


func _draw() -> void:
	# Sıcak atölye zemini (opak — açılışta yalnız bu görünür).
	draw_texture_rect(_bg, Rect2(Vector2.ZERO, size), false)

	# Boya-paleti logosu: yumuşak yay boyunca örtüşen damlalar + altlarında sıcak gölge.
	var logo_center := Vector2(size.x / 2.0, size.y * 0.28)
	var spread := 116.0
	var last := _PALETTE.size() - 1
	for i in _PALETTE.size():
		var t := float(i) / last - 0.5  # -0.5 .. 0.5
		var dab := logo_center + Vector2(t * 2.0 * spread, abs(t) * 34.0)
		_draw_dab(dab, 44.0, _PALETTE[i])

	# Oyun adı (wordmark) — gerçek font (Fredoka), koyu mürekkep, ortalı.
	var title_size := 76
	var text_w := _font_title.get_string_size(_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x
	draw_string(
		_font_title, Vector2(size.x / 2.0 - text_w / 2.0, size.y * 0.45),
		_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size, UITheme.INK
	)

	# "Kaldığın seviye" göstergesi: kil çip + büyük sayı + ilerleme çubuğu (dilden bağımsız).
	_draw_level_chip(Vector2(size.x / 2.0, size.y * 0.575))


## Tek boya damlası: sıcak gölge + gövde + sol-üst parlaklık (cozy boya hissi).
func _draw_dab(center: Vector2, radius: float, color: Color) -> void:
	draw_circle(center + Vector2(0, 5), radius, UITheme.SHADOW)  # yumuşak gölge
	draw_circle(center, radius, color)
	var gloss := color.lightened(0.35)
	gloss.a = 0.5
	draw_circle(center - Vector2(radius * 0.28, radius * 0.30), radius * 0.42, gloss)


## Kil yüzeyli çip: ortada "N / M" + altında altın ilerleme çubuğu.
func _draw_level_chip(center: Vector2) -> void:
	var chip_size := Vector2(232, 96)
	var rect := Rect2(center - chip_size / 2.0, chip_size)
	var box := UITheme.clay_box(UITheme.SURFACE, UITheme.SURFACE_LINE, 8, 5.0)
	draw_style_box(box, rect)

	# Büyük mevcut seviye numarası (gerçek font).
	var big := 42
	var num := str(_current)
	var num_w := _font_num.get_string_size(num, HORIZONTAL_ALIGNMENT_LEFT, -1, big).x
	# " / M" küçük ve soluk.
	var small := 22
	var frac := " / %d" % _total
	var frac_w := _font_num.get_string_size(frac, HORIZONTAL_ALIGNMENT_LEFT, -1, small).x
	var total_w := num_w + frac_w
	var base_x := center.x - total_w / 2.0
	var text_y := center.y - 6.0
	draw_string(_font_num, Vector2(base_x, text_y), num, HORIZONTAL_ALIGNMENT_LEFT, -1, big, UITheme.INK)
	draw_string(_font_num, Vector2(base_x + num_w, text_y), frac, HORIZONTAL_ALIGNMENT_LEFT, -1, small, UITheme.INK_SOFT)

	# İlerleme çubuğu (altın dolgu).
	var bar_w := chip_size.x - 40.0
	var bar := Rect2(center.x - bar_w / 2.0, rect.position.y + chip_size.y - 22.0, bar_w, 8.0)
	var track := StyleBoxFlat.new()
	track.bg_color = UITheme.BG_BOTTOM
	track.set_corner_radius_all(4)
	draw_style_box(track, bar)
	var ratio: float = clampf(float(_current) / float(maxi(_total, 1)), 0.0, 1.0)
	if ratio > 0.0:
		var fill := StyleBoxFlat.new()
		fill.bg_color = UITheme.GOLD
		fill.set_corner_radius_all(4)
		draw_style_box(fill, Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)))

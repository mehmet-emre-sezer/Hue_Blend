class_name UITheme
extends RefCounted

## Ortak görsel sistem: SICAK-AÇIK ATÖLYE paleti + GERÇEK ASSET butonlar (Kenney UI, CC0).
## TEK kaynak — renk/font/buton token'ları burada (Clean: sihirli sayı/hardcode renk yok).
## Butonlar 9-patch texture (StyleBoxTexture), elle çizim değil.

# Sıcak-açık atölye paleti
const BG_TOP := Color("fbf3e2")       # krem kâğıt (üst, aydınlık)
const BG_BOTTOM := Color("efdfc2")    # sıcak bej (alt)
const INK := Color("4a3b2a")          # koyu kahve metin (kontrast ≥ 4.5:1)
const INK_SOFT := Color("9a8266")     # ikincil metin (yumuşak taupe)
const CLAY := Color("f2b56b")         # kil turuncu (birincil buton)
const CLAY_INK := Color("5a3d1e")     # kil buton üstü metin
const GOLD := Color("f4c542")         # ödül altını (aksan/ilerleme)
const SURFACE := Color("fffaf0")      # kart/çip yüzeyi
const SURFACE_LINE := Color("d9c3a0") # yüzey kenarı
const SHADOW := Color(0.45, 0.34, 0.22, 0.30)  # sıcak yumuşak gölge

const CORNER := 22
const BORDER := 3

# Gerçek font asset'i (Fredoka, OFL). Variable — ağırlık variation ile ayarlanır.
const FREDOKA := preload("res://assets/fonts/Fredoka.ttf")


## Temel (Regular) font.
static func font() -> Font:
	return FREDOKA


## Belirli ağırlıkta font (400 Regular … 700 Bold). Başlık/buton için 600 önerilir.
static func font_weight(weight: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = FREDOKA
	var tag := TextServerManager.get_primary_interface().name_to_tag("weight")
	fv.variation_opentype = {tag: weight}
	return fv


## Kil kutusu: yumuşak gölge + kalın yuvarlak kenar (claymorphism gövdesi).
static func clay_box(base: Color, border: Color, shadow_size: int, shadow_y: float) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = base
	box.set_corner_radius_all(CORNER)
	box.set_border_width_all(BORDER)
	box.border_color = border
	box.shadow_color = SHADOW
	box.shadow_size = shadow_size
	box.shadow_offset = Vector2(0, shadow_y)
	box.set_content_margin_all(16)
	box.anti_aliasing = true
	return box


# Gerçek buton asset'leri (Kenney UI Pack, CC0). 9-patch — köşeler bozulmadan esner.
const BTN_PRIMARY := preload("res://assets/ui/btn_primary.png")            # sarı (birincil)
const BTN_PRIMARY_DOWN := preload("res://assets/ui/btn_primary_down.png")
const BTN_NEUTRAL := preload("res://assets/ui/btn_neutral.png")            # gri (nötr)
const BTN_NEUTRAL_DOWN := preload("res://assets/ui/btn_neutral_down.png")
const BTN_SQUARE := preload("res://assets/ui/btn_square.png")              # kare (ikon)
const BTN_SQUARE_DOWN := preload("res://assets/ui/btn_square_down.png")
const PANEL := preload("res://assets/ui/panel.png")                        # düz yuvarlak panel
const PAPER := preload("res://assets/textures/paper.jpg")                  # sıcak kâğıt dokusu (zemin)
const PAPER_TINT := Color(1.12, 1.06, 0.92)                                # gri kâğıdı sıcak kreme çeker


## Panel/çip zemini: gerçek Kenney panel texture (sıcak tona modüle). draw_style_box ile çizilir.
static func panel_box(content: int) -> StyleBoxTexture:
	var box := _tex_box(PANEL, 22, 22, content)
	box.modulate_color = SURFACE  # gri paneli sıcak krem tona çek
	return box


## 9-patch texture kutusu: kenar payları köşeleri korur, iç pay metni/ikonu boşluklar.
static func _tex_box(tex: Texture2D, edge: int, edge_bottom: int, content: int) -> StyleBoxTexture:
	var box := StyleBoxTexture.new()
	box.texture = tex
	box.texture_margin_left = edge
	box.texture_margin_right = edge
	box.texture_margin_top = edge
	box.texture_margin_bottom = edge_bottom
	box.set_content_margin_all(content)
	return box


## Metin/geniş buton: gerçek Kenney texture (primary=sarı, değilse gri). Basılınca "iner".
static func style_button(btn: Button, primary: bool, font_size: int) -> void:
	btn.add_theme_font_override("font", font_weight(600))
	btn.add_theme_font_size_override("font_size", font_size)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		btn.add_theme_color_override(state, INK)
	var up: Texture2D = BTN_PRIMARY if primary else BTN_NEUTRAL
	var down: Texture2D = BTN_PRIMARY_DOWN if primary else BTN_NEUTRAL_DOWN
	btn.add_theme_stylebox_override("normal", _tex_box(up, 22, 28, 14))
	btn.add_theme_stylebox_override("hover", _tex_box(up, 22, 28, 14))
	btn.add_theme_stylebox_override("pressed", _tex_box(down, 22, 18, 14))
	btn.add_theme_stylebox_override("focus", _tex_box(up, 22, 28, 14))


## Kare ikon butonu: gri kare texture + ortalanmış (Lucide) ikon.
static func style_icon_button(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", _tex_box(BTN_SQUARE, 20, 26, 12))
	btn.add_theme_stylebox_override("hover", _tex_box(BTN_SQUARE, 20, 26, 12))
	btn.add_theme_stylebox_override("pressed", _tex_box(BTN_SQUARE_DOWN, 20, 16, 12))
	btn.add_theme_stylebox_override("focus", _tex_box(BTN_SQUARE, 20, 26, 12))
	for state in ["icon_normal_color", "icon_hover_color", "icon_pressed_color"]:
		btn.add_theme_color_override(state, INK)
	btn.expand_icon = true

class_name UITheme
extends RefCounted

## Ortak görsel sistem: SICAK-AÇIK ATÖLYE paleti + claymorphism buton stilleri.
## TEK kaynak — renk/gölge/köşe token'ları burada (Clean: sihirli sayı/hardcode renk yok).
## Kod-üretimli StyleBox ile kil hissi (assetsiz); gerçek asset'ler sonra üstüne cila.

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


## Bir Button'a kil stilini uygular: normal/hover/pressed (basılıyken gölge küçülür = "bastı" hissi).
static func style_clay_button(btn: Button, base: Color, ink: Color, font_size: int) -> void:
	btn.add_theme_font_override("font", font_weight(600))
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", ink)
	btn.add_theme_color_override("font_hover_color", ink)
	btn.add_theme_color_override("font_pressed_color", ink)
	btn.add_theme_stylebox_override("normal", clay_box(base, base.darkened(0.14), 10, 6.0))
	btn.add_theme_stylebox_override("hover", clay_box(base.lightened(0.06), base.darkened(0.14), 12, 7.0))
	var pressed := clay_box(base.darkened(0.10), base.darkened(0.20), 4, 2.0)
	btn.add_theme_stylebox_override("pressed", pressed)

class_name WinOverlay
extends Control

## Kazanç kutlaması (dilden bağımsız — metin yok): karartma + yumuşak hale +
## pop-in altın yıldız + parıltı patlaması. Dokununca devam. Asset: Kenney (CC0).

signal continue_requested

const STAR := preload("res://assets/fx/star.png")       # dolu yıldız
const SPARKLE := preload("res://assets/fx/sparkle.png")  # partikül parıltısı
const GLOW := preload("res://assets/fx/glow.png")        # yumuşak hale

const STAR_SCALE := 2.2
const GOLD := Color("ffcf3f")

var _glow: Sprite2D
var _star: Sprite2D
var _particles: CPUParticles2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	_glow = Sprite2D.new()
	_glow.texture = GLOW
	_glow.modulate = Color(1.0, 0.88, 0.45, 0.0)
	add_child(_glow)

	_star = Sprite2D.new()
	_star.texture = STAR
	_star.modulate = GOLD
	_star.scale = Vector2.ZERO
	add_child(_star)

	_particles = CPUParticles2D.new()
	_particles.texture = SPARKLE
	_particles.emitting = false
	_particles.one_shot = true
	_particles.explosiveness = 0.95
	_particles.amount = 28
	_particles.lifetime = 1.0
	_particles.direction = Vector2(0, -1)
	_particles.spread = 180.0
	_particles.initial_velocity_min = 180.0
	_particles.initial_velocity_max = 440.0
	_particles.gravity = Vector2(0, 320)
	_particles.scale_amount_min = 0.05
	_particles.scale_amount_max = 0.13
	_particles.angular_velocity_min = -220.0
	_particles.angular_velocity_max = 220.0
	_particles.color = Color("ffd24a")
	add_child(_particles)

	hide()


func show_win(screen_size: Vector2, reduced_motion: bool = false) -> void:
	size = screen_size
	position = Vector2.ZERO
	var center := screen_size / 2.0
	_glow.position = center
	_star.position = center
	_particles.position = center
	show()
	queue_redraw()

	if reduced_motion:
		_star.scale = Vector2(STAR_SCALE, STAR_SCALE)
		_glow.scale = Vector2(1.4, 1.4)
		_glow.modulate.a = 0.8
		return

	# Yıldız pop-in (elastik), hale açılışı + parıltı patlaması.
	_star.scale = Vector2.ZERO
	_glow.scale = Vector2(0.6, 0.6)
	_glow.modulate.a = 0.0
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_star, "scale", Vector2(STAR_SCALE, STAR_SCALE), 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_glow, "scale", Vector2(1.45, 1.45), 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(_glow, "modulate:a", 0.85, 0.4)
	_particles.restart()
	_particles.emitting = true


func _gui_input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventScreenTouch and event.pressed) \
		or (event is InputEventMouseButton and event.pressed)
	if tapped:
		continue_requested.emit()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.15, 0.11, 0.06, 0.6))  # sıcak karartma

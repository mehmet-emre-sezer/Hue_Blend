class_name Settings
extends RefCounted

## Kullanıcı ayarları (kalıcı, sürümlü). İlerlemeden AYRI dosya (CFG-001 ayrım).
## Ayarlar: reduced_motion (animasyonları kapatır), colorblind_mode (renk körü sembolleri).
## Renk körü sembolleri VARSAYILAN KAPALI, isteyen açar (erişilebilirlik opsiyonel).
## Yol enjekte edilir (test edilebilirlik, global durum yok).

const CURRENT_VERSION := 1

var reduced_motion := false
var colorblind_mode := false

var _path: String


func _init(path: String = "user://settings.json") -> void:
	_path = path
	_load()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	_save()


func set_colorblind_mode(value: bool) -> void:
	colorblind_mode = value
	_save()


func _save() -> void:
	var data := {
		"version": CURRENT_VERSION,
		"reduced_motion": reduced_motion,
		"colorblind_mode": colorblind_mode,
	}
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if file == null:
		push_error("Ayarlar yazılamadı: %s" % _path)
		return
	file.store_string(JSON.stringify(data))


func _load() -> void:
	if not FileAccess.file_exists(_path):
		return  # ayar yok → varsayılanlar
	var file := FileAccess.open(_path, FileAccess.READ)
	if file == null:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
	var parsed: Variant = json.data
	if not (parsed is Dictionary):
		return
	if int(parsed.get("version", 0)) != CURRENT_VERSION:
		return
	reduced_motion = bool(parsed.get("reduced_motion", false))
	colorblind_mode = bool(parsed.get("colorblind_mode", false))

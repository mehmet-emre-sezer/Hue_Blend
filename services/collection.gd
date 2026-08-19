class_name Collection
extends RefCounted

## Keşfedilmiş renklerin kalıcı kümesi (retention/başarım — renk açma meta katmanı).
## İlk kez üretilen her renk buraya eklenir. Sürümlü, ilerlemeden ayrı dosya (CFG-001).

const CURRENT_VERSION := 1

var _discovered: Dictionary = {}  # StringName -> true
var _path: String


func _init(path: String = "user://collection.json") -> void:
	_path = path
	_load()


func has(id: StringName) -> bool:
	return _discovered.has(id)


## Rengi keşfeder. YENİ ise true döner (ve kaydeder); zaten biliniyorsa false (yazma yok).
func discover(id: StringName) -> bool:
	if _discovered.has(id):
		return false
	_discovered[id] = true
	_save()
	return true


func count() -> int:
	return _discovered.size()


func _save() -> void:
	var ids := PackedStringArray()
	for id in _discovered:
		ids.append(String(id))
	var data := {"version": CURRENT_VERSION, "ids": ids}
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if file == null:
		push_error("Koleksiyon yazılamadı: %s" % _path)
		return
	file.store_string(JSON.stringify(data))


func _load() -> void:
	if not FileAccess.file_exists(_path):
		return
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
	for id_str in parsed.get("ids", []):
		_discovered[StringName(id_str)] = true

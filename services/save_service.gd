class_name SaveService
extends RefCounted

## İlerlemeyi yerel diske yazar/okur. Sürümlü (RES-020); "yok" ≠ "bozuk" (RES-026).
## Yol enjekte edilir (test edilebilirlik, global durum yok — SIN/Clean §5).

const CURRENT_VERSION := 1

var _path: String


func _init(path: String = "user://save.json") -> void:
	_path = path


func save_progress(level_index: int) -> void:
	var data := {"version": CURRENT_VERSION, "level_index": level_index}
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if file == null:
		push_error("Kayıt yazılamadı: %s" % _path)
		return
	file.store_string(JSON.stringify(data))


## Kayıtlı seviye index'ini döner. Kayıt yok / bozuk / uyumsuz sürüm → 0 (baştan başla).
func load_level_index() -> int:
	if not FileAccess.file_exists(_path):
		return 0  # "yok" → baştan (RES-026)
	var file := FileAccess.open(_path, FileAccess.READ)
	if file == null:
		return 0
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("Kayıt bozuk (JSON), sıfırlanıyor: %s" % _path)
		return 0
	var parsed: Variant = json.data
	if not (parsed is Dictionary):
		push_warning("Kayıt bozuk (biçim), sıfırlanıyor: %s" % _path)
		return 0
	if int(parsed.get("version", 0)) != CURRENT_VERSION:
		return 0  # ileride sürüm göçü; şimdilik uyumsuz → baştan
	return int(parsed.get("level_index", 0))

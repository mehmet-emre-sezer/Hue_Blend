class_name ColorRegistry
extends RefCounted

## Tüm ColorCard'ların sahibi ve id ile erişim noktası (TYPE-010).
## Enjekte edilir, GLOBAL SINGLETON DEĞİL (SIN-022): oyun/testler kendi registry'sini kurar.
## Eksik/çift ID deterministik ele alınır (TYPE-011, RES-024/026).

var _by_id: Dictionary = {}  # StringName -> ColorCard


## Bir kartı kaydeder. Çift ID sessizce ÜZERİNE YAZMAZ (RES-024): ilk kayıt korunur.
func register(card: ColorCard) -> void:
	assert(card != null, "null ColorCard register edilemez")
	assert(card.id != StringName(""), "ColorCard.id boş olamaz")
	if _by_id.has(card.id):
		push_warning("Çift renk ID yok sayıldı, ilk kayıt korunuyor: %s" % card.id)
		return
	_by_id[card.id] = card


func has(id: StringName) -> bool:
	return _by_id.has(id)


## Bilinen kartı döner; bilinmeyen id için null ("yok" deterministik — RES-026).
## Anlamlı hata bağlamı, id'yi kullanan katmanda üretilir (ör. LevelLoader, ERR-004).
func get_card(id: StringName) -> ColorCard:
	return _by_id.get(id, null)


func size() -> int:
	return _by_id.size()

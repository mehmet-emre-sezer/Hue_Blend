class_name MixRules
extends RefCounted

## İki temel rengin karışımını tanımlayan tablo (veri — Type Object ruhu).
## Sıra önemsiz: mavi+sarı == sarı+mavi. Faz 2 Aşama 1: yalnız temel+temel → ikincil.

var _table: Dictionary = {}  # String anahtar -> ColorCard (sonuç)


func add(a: StringName, b: StringName, result: ColorCard) -> void:
	_table[_key(a, b)] = result


## a+b karışımının sonucu; tanımsızsa null.
func result_of(a: StringName, b: StringName) -> ColorCard:
	return _table.get(_key(a, b), null)


func _key(a: StringName, b: StringName) -> String:
	var sa := String(a)
	var sb := String(b)
	return sa + "+" + sb if sa <= sb else sb + "+" + sa

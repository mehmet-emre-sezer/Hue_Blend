class_name Tube
extends RefCounted

## Bir tüp: sıralı ColorCard yığını + kapasite. Kendi yığınının sahibi (X-008).
## Saf mantık — Godot düğümü/pixel bilmez, headless test edilebilir (TDD §3).
## Yığın: index 0 = dip, son eleman = üst.

var _capacity: int
var _stack: Array[ColorCard] = []


func _init(capacity: int) -> void:
	assert(capacity > 0, "kapasite pozitif olmalı")
	_capacity = capacity


func capacity() -> int:
	return _capacity


func size() -> int:
	return _stack.size()


func is_empty() -> bool:
	return _stack.is_empty()


func is_full() -> bool:
	return _stack.size() == _capacity


func free_space() -> int:
	return _capacity - _stack.size()


## Üstteki kart (boşsa null).
func top() -> ColorCard:
	return _stack[-1] if not _stack.is_empty() else null


## Üstten başlayarak bitişik aynı-renk kartların sayısı (su-ayırma: birlikte taşınan grup).
func top_run_count() -> int:
	if _stack.is_empty():
		return 0
	var top_card := _stack[-1]
	var count := 0
	for i in range(_stack.size() - 1, -1, -1):
		if _stack[i].same_as(top_card):
			count += 1
		else:
			break
	return count


## Bu tüp verilen kartı kabul eder mi: dolu değil VE (boş VEYA üst aynı renk).
func can_accept(card: ColorCard) -> bool:
	if card == null or is_full():
		return false
	return is_empty() or top().same_as(card)


## Kurulum/hamle: üste kart ekler.
func push_card(card: ColorCard) -> void:
	assert(card != null, "null kart push edilemez")
	assert(not is_full(), "dolu tüpe push edilemez")
	_stack.append(card)


## Hamle: üstteki kartı çıkarır ve döner.
func pop_card() -> ColorCard:
	assert(not is_empty(), "boş tüpten pop edilemez")
	return _stack.pop_back()


## Tüp içeriğini toptan değiştirir (hamle uygula/geri-al snapshot'ları için).
func replace(cards: Array) -> void:
	assert(cards.size() <= _capacity, "kapasiteyi aşan içerik")
	var new_stack: Array[ColorCard] = []
	for card in cards:
		new_stack.append(card)
	_stack = new_stack


## Çözülü mü: boş VEYA (dolu VE tek renk) (TDD §4).
func is_solved() -> bool:
	if is_empty():
		return true
	if not is_full():
		return false
	return _is_uniform()


## Sunum için güvenli okuma: yığının KOPYASI (dışarıdan mutasyonu önler — Clean §5).
func cards_snapshot() -> Array[ColorCard]:
	return _stack.duplicate()


func _is_uniform() -> bool:
	var first := _stack[0]
	for card in _stack:
		if not card.same_as(first):
			return false
	return true

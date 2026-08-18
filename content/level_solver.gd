class_name LevelSolver
extends RefCounted

## Bir seviyenin çözülebilir olup olmadığını arar (DFS + ziyaret kümesi, düğüm sınırlı).
## Successor'lar oyunun kendi kuralını (Pour.compute) kullanır → çözücü ile oyun asla sapmaz.
## Karışım-farkında: mix_rules verilirse karışım hamlelerini de dener (null → saf sıralama).

const NODE_LIMIT := 300000


func is_solvable(level: LevelData, colors: ColorRegistry, mix_rules: MixRules = null) -> bool:
	var capacity := level.capacity
	var start := _encode(level, colors)
	var visited := {_key(start): true}
	var stack: Array = [start]
	var nodes := 0

	while not stack.is_empty():
		nodes += 1
		if nodes > NODE_LIMIT:
			return false  # sınır aşıldı → "bilinmiyor", çözülemez say
		var state: Array = stack.pop_back()
		if _is_solved(state, capacity):
			return true
		for successor in _successors(state, capacity, mix_rules):
			var key := _key(successor)
			if not visited.has(key):
				visited[key] = true
				stack.append(successor)
	return false


func _encode(level: LevelData, colors: ColorRegistry) -> Array:
	var out: Array = []
	for tube_ids in level.tubes:
		var tube: Array = []
		for id in tube_ids:
			tube.append(colors.get_card(StringName(id)))
		out.append(tube)
	return out


func _is_solved(state: Array, capacity: int) -> bool:
	for tube in state:
		if tube.is_empty():
			continue
		if tube.size() != capacity:
			return false
		var first: ColorCard = tube[0]
		for card in tube:
			if not card.same_as(first):
				return false
	return true


func _successors(state: Array, capacity: int, mix_rules: MixRules) -> Array:
	var out: Array = []
	var count := state.size()
	for i in count:
		for j in count:
			if i == j:
				continue
			var outcome := Pour.compute(state[i], state[j], capacity, mix_rules)
			if outcome != null:
				var next := state.duplicate()  # tüp listesi sığ kopya (iç diziler değişmez)
				next[i] = outcome.source_after
				next[j] = outcome.dest_after
				out.append(next)
	return out


## Tüp sırası önemsiz → tüpleri renk-id'leriyle sıralayıp birleştirerek kanonik anahtar.
func _key(state: Array) -> String:
	var parts: Array = []
	for tube in state:
		var ids: Array = []
		for card in tube:
			ids.append(String(card.id))
		parts.append(",".join(ids))
	parts.sort()
	return "|".join(parts)

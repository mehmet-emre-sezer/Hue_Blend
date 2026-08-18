class_name LevelSolver
extends RefCounted

## Bir seviyenin çözülebilir olup olmadığını arar (DFS + ziyaret edilmiş küme, düğüm sınırlı).
## Amaç: üretilen/tasarlanan seviyelerin gerçekten çözülebilir olduğunu garanti (PIPE-009, K3).
## Saf mantık, çekirdek kurallarını yeniden uygular (durum = tüp içerikleri dizisi).

const NODE_LIMIT := 300000


func is_solvable(level: LevelData) -> bool:
	var capacity := level.capacity
	var start := _encode(level)
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
		for successor in _successors(state, capacity):
			var key := _key(successor)
			if not visited.has(key):
				visited[key] = true
				stack.append(successor)
	return false


func _encode(level: LevelData) -> Array:
	var out: Array = []
	for tube_ids in level.tubes:
		var tube: Array = []
		for id in tube_ids:
			tube.append(id)
		out.append(tube)
	return out


func _is_solved(state: Array, capacity: int) -> bool:
	for tube in state:
		if tube.is_empty():
			continue
		if tube.size() != capacity:
			return false
		for unit in tube:
			if unit != tube[0]:
				return false
	return true


func _successors(state: Array, capacity: int) -> Array:
	var out: Array = []
	var count := state.size()
	for i in count:
		var source: Array = state[i]
		if source.is_empty():
			continue
		var color = source[-1]
		var run := 0
		for x in range(source.size() - 1, -1, -1):
			if source[x] == color:
				run += 1
			else:
				break
		for j in count:
			if i == j:
				continue
			var dest: Array = state[j]
			if dest.size() == capacity:
				continue
			if not (dest.is_empty() or dest[-1] == color):
				continue
			var move_count: int = min(run, capacity - dest.size())
			if move_count <= 0:
				continue
			out.append(_apply(state, i, j, move_count))
	return out


func _apply(state: Array, from_index: int, to_index: int, move_count: int) -> Array:
	var next: Array = []
	for tube in state:
		next.append(tube.duplicate())
	for c in move_count:
		next[to_index].append(next[from_index].pop_back())
	return next


## Tüp sırası önemsiz → tüpleri sıralayıp birleştirerek kanonik anahtar (ziyaret dedup).
func _key(state: Array) -> String:
	var parts: Array = []
	for tube in state:
		parts.append(",".join(tube))
	parts.sort()
	return "|".join(parts)

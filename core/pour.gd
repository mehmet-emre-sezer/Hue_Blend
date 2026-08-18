class_name Pour
extends RefCounted

## Dökme + karıştırma kuralının SAF hesabı (mutasyon yok, test edilebilir).
## Kaynak üst-grubu hedefe dökülür; hedef üstü uyumsuz ama karışabilir temel renkse
## arayüzde 1:1 çiftler ikincil renge döner, fazlalık kendi tarafında kalır:
##   fazla dökülen renk → üstte, fazla hedef renk → altta (kullanıcı spesifikasyonu).
## Geçersizse null döner.

static func compute(source: Array, dest: Array, dest_capacity: int, mix_rules: MixRules) -> PourOutcome:
	if source.is_empty():
		return null
	var free := dest_capacity - dest.size()
	if free <= 0:
		return null

	var poured: ColorCard = source[-1]
	var run := _top_run(source)
	var move_count := mini(run, free)
	if move_count <= 0:
		return null

	var new_source := source.slice(0, source.size() - move_count)
	var dest_top: ColorCard = dest[-1] if not dest.is_empty() else null

	# Saf dökme: hedef boş ya da aynı renk.
	if dest_top == null or dest_top.same_as(poured):
		var new_dest := dest.duplicate()
		for i in move_count:
			new_dest.append(poured)
		return PourOutcome.new(new_source, new_dest, move_count, poured, poured)

	# Karışım: hedef üstü farklı temel renk ve karışım tanımlı.
	if mix_rules != null:
		var result := mix_rules.result_of(poured.id, dest_top.id)
		if result != null:
			var m := _top_run(dest)          # hedefin üst grubu (B)
			var pairs := mini(move_count, m)  # eşleşen 1:1 çiftler
			var new_dest := dest.slice(0, dest.size() - m)  # B grubunun altı
			for i in (m - pairs):
				new_dest.append(dest_top)     # fazla hedef renk → altta
			for i in (2 * pairs):
				new_dest.append(result)       # karışan çiftler → ikincil
			for i in (move_count - pairs):
				new_dest.append(poured)       # fazla dökülen renk → üstte
			return PourOutcome.new(new_source, new_dest, move_count, poured, result)

	return null  # uyumsuz, karışım yok


static func _top_run(stack: Array) -> int:
	if stack.is_empty():
		return 0
	var top: ColorCard = stack[-1]
	var count := 0
	for i in range(stack.size() - 1, -1, -1):
		if stack[i].same_as(top):
			count += 1
		else:
			break
	return count

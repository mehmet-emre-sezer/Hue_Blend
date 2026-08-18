class_name LevelValidator
extends RefCounted

## Seviye iyi-biçim doğrulaması — bozuk içeriği OYUN sırasında değil yüklemede yakalar
## (PIPE-009, X-022). Hata listesi döner (boş = geçerli); anlamlı sonuç (Clean §4).
##
## Faz 1: yapısal (gerekli ama yeterli olmayan) kontroller. Tam çözücü (BFS) Faz 3'e
## ertelendi (TDD §K3) — el-yapımı seviyeler için yapısal doğrulama yeterli.

func validate(level: LevelData, colors: ColorRegistry) -> PackedStringArray:
	var errors := PackedStringArray()

	if level.capacity <= 0:
		errors.append("kapasite pozitif olmalı (mevcut: %d)" % level.capacity)
	if level.tubes.is_empty():
		errors.append("en az bir tüp gerekli")

	var color_counts := {}  # StringName -> int
	for i in level.tubes.size():
		var tube_ids := level.tubes[i]
		if level.capacity > 0 and tube_ids.size() > level.capacity:
			errors.append("tüp %d kapasiteyi aşıyor (%d > %d)" % [i, tube_ids.size(), level.capacity])
		for id_str in tube_ids:
			var id := StringName(id_str)
			if not colors.has(id):
				errors.append("bilinmeyen renk id: '%s' (tüp %d)" % [id_str, i])
			else:
				color_counts[id] = int(color_counts.get(id, 0)) + 1

	# Her rengin toplamı kapasiteye tam bölünmeli (tek-renk tüp doldurabilmenin ön koşulu).
	if level.capacity > 0:
		for id in color_counts:
			if color_counts[id] % level.capacity != 0:
				errors.append("renk '%s' toplamı (%d) kapasiteye (%d) bölünmüyor" % [id, color_counts[id], level.capacity])

	return errors

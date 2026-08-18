class_name LevelData
extends Resource

## Veri-odaklı seviye tanımı (.tres olarak yazılır — GEA-007, X-021).
## Çekirdek koda dokunmadan yeni seviye = yeni veri.

## Her tüpün kapasitesi (kart sayısı).
@export var capacity: int = 4

## Her tüp için başlangıç renk id'leri, dip→üst sırada. Boş dizi = boş tüp.
## Not: Godot Resource export kısıtı nedeniyle iç eleman PackedStringArray'dir
## (Clean §14 açık tip tercihinden sapma); tip güvenliği yükleme sınırında
## LevelValidator ile sağlanır (X-022).
@export var tubes: Array[PackedStringArray] = []

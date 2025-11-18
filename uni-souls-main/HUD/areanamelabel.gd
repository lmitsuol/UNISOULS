extends Label

var area_name_label = self

func set_area_name(name: String):
	text = name
	visible = true
	modulate.a = 0.0

	var tween = create_tween()
	
	# 1. FADE-IN: Anima a opacidade para 1.0 em 0.5s
	tween.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# PAUSA. Cria um intervalo de 2.0s
	tween.tween_interval(2.0)
	
	# 3. FADE-OUT: Anima a opacidade para 0.0 em 1.0s
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	
	# 4. AÇÃO FINAL: Torna o nó invisível
	tween.tween_callback(func(): visible = false)
	

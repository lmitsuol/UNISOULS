extends AudioStreamPlayer

# armazena diferentes faixas de música:
var music_tracks = {
	"floresta": preload("res://Music/Música para Unisouls.mp3"),
	"gameover": preload("res://Music/GameOver_Song.mp3"),
	"caverna": preload("res://Music/Musica unisouls 2.MP3"),
	"vila": preload("res://Music/Musica Unisouls 3.MP3"),
	"boss": preload("res://Music/Musica Unisouls 4.MP3"),
	"end": preload("res://Music/Triumphant Shadows.mp3")
}

var current_track = ""

func play_music(track_name: String):
	# Se a faixa pedida é a que já está tocando, não faz nada
	if track_name == current_track and playing:
		return
		
	# Verifica se a faixa existe no dicionário
	if music_tracks.has(track_name):
		stream = music_tracks[track_name]
		play()
		current_track = track_name
	else:
		print("ERRO: Faixa de música não encontrada: ", track_name)

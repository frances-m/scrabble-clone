extends Control

func _ready() -> void:
	%Player.text = get_player_name()
	%Score.set_meta("player", get_player())
	_set_color()
	Scorer.connect("word_played", Callable(self, "_add_word"))
	Globals.connect("change_player", Callable(self, "_on_player_change"))

func get_player() -> int:
	return get_meta("player", 0)

func get_player_name() -> String:
	return "Player {num}".format({ "num": get_player() })

func _set_color() -> void:
	var color = Color(0, 0, 0, .8)
	if get_player() != Globals.current_player:
		color.a = .6

	%ColorRect.color = color

func _add_word(word: String, score: int) -> void:
	if get_player() != Globals.current_player:
		return
	
	var settings = LabelSettings.new()
	settings.font_size = 20
	
	var word_label = Label.new()
	word_label.label_settings = settings
	word_label.text = word
	%Words.add_child(word_label)
	
	var score_label = Label.new()
	score_label.label_settings = settings
	score_label.text = str(score)
	%Scores.add_child(score_label)

func _on_player_change() -> void:
	_set_color()

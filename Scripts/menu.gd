extends Control

@onready var label: RichTextLabel = $ForegroundLayer/IntroLabel
@onready var info_label: RichTextLabel = $ForegroundLayer/InfoLabel
@onready var startBtn: Button = $ForegroundLayer/StartBtn
@onready var tutorialBtn: Button = $ForegroundLayer/TutorialBtn
@export_file("*.tscn") var game_scene_path: String = "res://Scenes/main_scene.tscn"
var fade_time := 0.25

var lines := [
	"...As estrelas a brillar, e os mariñeiros ao mar…",
	"Xa se escoita, desde Udra, o zunido da sirena: vai sendo hora de ir á marea.",
	"Dorna negra, como as augas, entre os farrapos de néboa. ",
	"Mentres tanto, desde a Pobra, chega a música da festa.",
	"Non esquecer a menciña pra pasar a noite mesta: augardente do da casa, canto presta!",
]

var index := 0
var busy := 0
var showing_intro := false;

func _ready() -> void:
	label.clear()
	label.modulate.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not showing_intro or busy:
		return
	if event is InputEventKey and event.echo:
		return
	if showing_intro and event.is_action_pressed("ui_accept") and not busy:
		_show_next_line()
		
func _show_next_line() -> void:
	if index >= lines.size():
		get_tree().change_scene_to_file(game_scene_path)
		return
		
	busy = true
	if label.text.is_empty():
		label.text = lines[index]
	else:
		label.text += "\n" + lines[index]
	
	index += 1
	label.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(label, "modulate:a", 1.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished
	
	busy = false

func _on_start_btn_pressed() -> void:
	info_label.visible = true
	var t := create_tween()
	t.set_parallel()
	t.tween_property(startBtn, "modulate:a", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(tutorialBtn, "modulate:a", 0.0, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(info_label, "modulate:a", 0.8, fade_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished
	startBtn.visible = false
	label.visible = true
	showing_intro = true
	_show_next_line()
	
	

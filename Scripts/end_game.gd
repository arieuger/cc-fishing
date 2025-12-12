extends Control

@onready var label: RichTextLabel = $ForegroundLayer/IntroLabel
@export_file("*.tscn") var game_scene_path: String = "res://Scenes/menu.tscn"
var fade_time := 0.25
var instantiated := false

var lines := [
	"Estraña foi a marea, abofé.",
	"Nestas augas fulgurantes vin seres nunca avistados, manxares descoñecidos, tesouros asolagados.",
	"Pero… ai de min! Que é a riqueza? Se o que ansío non o atopo, e por máis que vogue e vogue xamais chego a ver o rostro daquel que levou meu pai alá de onde non se volve",
	"Monstro! Monstro! ",
	"O mais grande que pesquei despois desta infausta viaxe foi aquel trombón de varas, unha monstruosa ausencia e unha chea importante.",
	"Importante como un polbo",
	"Como un polbo xigante."
]

var index := 0
var busy := 0

func _ready() -> void:
	label.clear()
	label.modulate.a = 0.0
	label.visible = true
	_show_next_line()

func _unhandled_input(event: InputEvent) -> void:
	if busy:
		return
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("ui_accept") and not busy:
		_show_next_line()
		
func _show_next_line() -> void:
	if index >= lines.size():
		# get_tree().change_scene_to_file(game_scene_path)
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

	
	

extends Sprite2D

@onready var mat := self.material as ShaderMaterial

func _ready() -> void:
	start_flicker()

func start_flicker():
	var tween := create_tween().set_loops()
	
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(mat, "shader_parameter/intensity", 0.1, 1.5)
	tween.tween_property(mat, "shader_parameter/intensity", 1.35, 1.5)
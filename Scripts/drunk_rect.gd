extends ColorRect

@onready var mat := self.material as ShaderMaterial

func _process(delta: float) -> void:
	var drunk := GameManager.boat.drunk_amount * 0.75
	mat.set_shader_parameter("strength", drunk)
	var t: float = mat.get_shader_parameter("time")
	t += delta
	mat.set_shader_parameter("time", t)

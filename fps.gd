extends Label

func  _physics_process(delta: float) -> void:
	
	text = str("FPS: " + str(Engine.get_frames_per_second()))

extends Button

func _on_pressed():
	open_dlc()

func open_dlc():
	var Exepath = OS.get_executable_path().get_base_dir()
	var path = Exepath + "/DLC/christmas pixel.pck"
	var dlc = ProjectSettings.load_resource_pack(path, true)
	
	if dlc:
		get_tree().change_scene_to_file("res://signin.tscn")
		print("done")
	else:
		print("Fail")

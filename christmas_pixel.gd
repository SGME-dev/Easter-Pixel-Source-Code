extends Button

func _on_pressed():
	extract_all_from_zip()
	$"../Timer".start()

# Extract all files from a ZIP archive, preserving the directories within.
# This acts like the "Extract all" functionality from most archive managers.
func extract_all_from_zip():
	var Exepath = OS.get_executable_path().get_base_dir()
	var reader = ZIPReader.new()
	reader.open(Exepath + "/DLC/Christmas Pixel/Christmas_Pixel_DLC.zip")
	
	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	var root_dir = DirAccess.open(Exepath + "/DLC/Christmas Pixel/")
	
	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue
			
		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)


func _on_timer_timeout() -> void:
	var platform_name: String = OS.get_name()
	if platform_name == "Windows":
		var Exepath = OS.get_executable_path().get_base_dir()
		var path = Exepath + "/DLC/Christmas Pixel/Christmas_Pixel_DLC/christmas pixel.dlc"
		var args = []
		OS.execute(path, args)
		get_tree().quit()
	if platform_name == "Linux":
		var Exepath = OS.get_executable_path().get_base_dir()
		OS.execute("chmod", ["+x", Exepath + "/DLC/Christmas Pixel/Christmas_Pixel_DLC/startdlc.sh"])
		OS.shell_open(Exepath + "/DLC/Christmas Pixel/Christmas_Pixel_DLC/startdlc.sh")

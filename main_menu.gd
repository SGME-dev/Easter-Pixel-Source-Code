extends Control

var skintrue: bool = false



func _on_play_pressed() -> void:
	$CanvasLayer/TextEdit.show()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://lobby.tscn")


func _on_back_pressed() -> void:
	$CanvasLayer/TextEdit.hide()


func _on_button1_pressed() -> void:
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://signin.tscn")


func _on_button_2_pressed() -> void:
	Firebase.Auth.delete_user_account()
	get_tree().change_scene_to_file("res://signin.tscn")


func _on_back2_pressed() -> void:
	$CanvasLayer/settings.hide()




func _on_settings_pressed() -> void:
	$CanvasLayer/settings.show()

func open_website(url: String):
	OS.shell_open(url)


func _on_bible_verses_pressed() -> void:
	open_website("https://sites.google.com/view/easter-pixel/home/easter-bible-verses")


func _on_website_pressed() -> void:
	open_website("https://sites.google.com/view/easter-pixel/home")

func open_email(email_address: String):
	var mailto_url = "mailto:" + email_address
	OS.shell_open(mailto_url)


func _on_support_pressed() -> void:
	
	open_email("easter-pixel-support@googlegroups.com")
	


func _on_button_3_pressed() -> void:
	save_username()

func save_username():
	var saveusername = FileAccess.open("user://username.save", FileAccess.WRITE)
	saveusername.store_string($CanvasLayer/settings/VBoxContainer/username.text)
	


func _on_parkore_pressed() -> void:
	get_tree().change_scene_to_file("res://parkore_skills.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_button_4_pressed() -> void:
	var saveskin = FileAccess.open("user://skin.save", FileAccess.WRITE)
	saveskin.store_string($CanvasLayer/settings/VBoxContainer/LineEdit.text)
	skintrue = true
	var savetrueskin = FileAccess.open("user://skintrue.save", FileAccess.WRITE)
	savetrueskin.store_var(skintrue)
	


func _on_quiz_pressed() -> void:
	get_tree().change_scene_to_file("res://quiz.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://CREDITS/GodotCredits.tscn")

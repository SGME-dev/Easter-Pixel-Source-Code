extends Node

var skintrue: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	
	if Firebase.Auth.check_auth_file():
		%StateLabel.text = "Logged in"
		get_tree().change_scene_to_file("res://main_menu.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_login_button_pressed():
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	Firebase.Auth.login_with_email_and_password(email, password)
	%StateLabel.text = "Logging in"
	save_username()
	var saveskin = FileAccess.open("user://skin.save", FileAccess.WRITE)
	saveskin.store_string("res://New Piskel (9) (10).png")
	var savetrueskin = FileAccess.open("user://skintrue.save", FileAccess.WRITE)
	savetrueskin.store_var(skintrue)
	

func _on_signup_button_pressed():
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	var username = %UsernameLineEdit.text
	Firebase.Auth.signup_with_email_and_password(email, password)
	%StateLabel.text = "Singing up"
	save_username()
	var saveskin = FileAccess.open("user://skin.save", FileAccess.WRITE)
	saveskin.store_string("res://New Piskel (9) (10).png")
	var savetrueskin = FileAccess.open("user://skintrue.save", FileAccess.WRITE)
	savetrueskin.store_var(skintrue)
	


func on_login_succeeded(auth):
	print(auth)
	%StateLabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://main_menu.tscn")
	save_username()
	

func on_signup_succeeded(auth):
	print(auth)
	%StateLabel.text = "Sign up success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
	
func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Login failed. Error: %s" % message
	
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Sign up failed. Error: %s" % message


func _on_signinwithgoogle_pressed() -> void:
	var provider: AuthProvider = Firebase.Auth.get_GoogleProvider()
	if OS.get_name() == "Web":
		# For web
		Firebase.Auth.set_redirect_uri("https://easter-pixel.firebaseapp.com")
		Firebase.Auth.get_auth_with_redirect(provider)
		save_username()
	else:
		# For desktop
		Firebase.Auth.get_auth_localhost(provider, 8060)
		save_username()
	var saveskin = FileAccess.open("user://skin.save", FileAccess.WRITE)
	saveskin.store_string("res://New Piskel (9) (10).png")
	var savetrueskin = FileAccess.open("user://skintrue.save", FileAccess.WRITE)
	savetrueskin.store_var(skintrue)
	




func save_username():
	var saveusername = FileAccess.open("user://username.save", FileAccess.WRITE)
	saveusername.store_string(%UsernameLineEdit.text)
	

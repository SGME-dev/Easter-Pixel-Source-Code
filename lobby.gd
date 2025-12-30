extends Node3D

class_name lobby

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var http_request: HTTPRequest = $CanvasLayer/HTTPRequest
@onready var lan_ip_label: Label = $CanvasLayer/Label
@onready var public_ip_label: Label = $CanvasLayer/Label2
var local_addresses = IP.get_local_addresses()
var actual_port: int = 15780
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 20
var user = FileAccess.open("user://username.save", FileAccess.READ).get_line()
@export var dedserver: bool = false


static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func is_dedicated_server():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--headless":
			return true
	return false

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	var Exepath = OS.get_executable_path().get_base_dir()
	print(Exepath)
	if OS.has_feature("dedicated_server"):
		print("Started the server...")
		_on_host_pressed()
		%host.hide()
		%join.hide()
		%LineEdit.hide()
		%LineEdit2.hide()
		$Sprite3D38.hide()
		dedserver = true
	
	

func _notification(what: int) -> void:
	# 2. Check if the user clicked the 'X' or pressed Alt+F4
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("NA")
		get_tree().quit()

func _on_host_pressed() -> void:
	
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	multiplayer.get_peers()
	
	# Connect the request_completed signal to our handler function.
	# This signal is emitted when the HTTP request finishes, whether successful or not.
	http_request.request_completed.connect(_on_http_request_completed)
	
	print("--- Attempting to get Public WAN IPv4 Address ---")
	public_ip_label.text = "Fetching Public IP..." # Update label to show fetching status
	
	# Make an HTTP GET request to a service that returns the public IP.
	# icanhazip.com is a simple service that returns the IP address as plain text.
	var error = http_request.request("https://ipv4.icanhazip.com")
	
	if error != OK:
		# If there was an error initiating the request (e.g., invalid URL, no network interface).
		print("Failed to start HTTP request: ", error)
		public_ip_label.text = "Error: Failed to start request."
	
	
	
	
	# --- LAN IP Address Retrieval ---
	print("--- IPv4 Addresses ---")
	var local_addresses = IP.get_local_addresses()
	
	var found_desired_ipv4 = false
	var current_lan_ip = "Not Found" 
	
	for address in local_addresses:
		if "." in address and ":" not in address:
			if address.begins_with("192.168.") or \
			   address.begins_with("10.") or \
			   (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				
				print("Lan IPV4 address: " + address)
				lan_ip_label.text = str("(Use For LAN)Private IPv4 Address: ", address)
				current_lan_ip = address
				found_desired_ipv4 = true
				break
	
	if not found_desired_ipv4:
		print("No suitable local IPv4 address found (e.g., not in common private ranges).")
		lan_ip_label.text = "Lan IPV4 address: Not Found"
	if local_addresses.is_empty():
		print("No local addresses found at all.")
		lan_ip_label.text = "Lan IPV4 address: No Addresses"
	
	
	print(dedserver)
	
	
	# --- Your existing UI/Animation code ---
	$StaticBody3D16/AnimationPlayer.play("move")
	$Narrorator/AudioStreamPlayer.play()
	%host.hide()
	%join.hide()
	%LineEdit.hide()
	%LineEdit2.hide()
	$Sprite3D38.hide()
	$CanvasLayer/Panel.hide()
	
	

func _on_join_pressed(address: String = str(%LineEdit.text), port: int = int(%LineEdit2.text)) -> void:
	if address.is_empty() or address == "localhost":
		address = DEFAULT_SERVER_IP
	if %LineEdit2.text.is_empty():
		port = actual_port
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	$StaticBody3D16/AnimationPlayer.play("move")
	
	%host.hide()
	%join.hide()
	%LineEdit.hide()
	%LineEdit2.hide()
	$Sprite3D38.hide()
	$CanvasLayer/Panel.hide()
	
	print(user + " joined the game")
	$CanvasLayer/Timer.start()


func add_player(id: int = 1) -> void:
	var player: CharacterBody3D = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	

func exit_game(id: int) -> void:
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)


func del_player(id: int) -> void:
	rpc("_del_player" ,id)
	
@rpc("any_peer","call_local")
func  _del_player(id: int) -> void:
	get_node(str(id)).queue_free()
	

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null


func _on_area_3d_body_entered(body: AnimatableBody3D) -> void:
	if body.is_in_group("jesus_donkey"):
		body.hide()


func _on_area_3d2_body_entered(body: player) -> void:
	set_active_environment($WorldEnvironment2)
	$CanvasLayer/TextEdit.text = "Later, on the night, Jesus was having a passover meal with his disiples."
	$Narrorator/AudioStreamPlayer3.play()
	


func _on_area_3d_2_body_entered(body: player) -> void:
	body.global_position = $HTerrain.global_position
	$AnimatableBody3D86/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "Jesus went to a garden to pray."
	$Narrorator/AudioStreamPlayer5.play()
	


func _on_area_3d_3_body_entered(body: player) -> void:
	body.global_position = $Sprite3D30.global_position
	$CanvasLayer/TextEdit.text = "The pharisies and sadusees asked Jesus alot of questions. They did not care what jesus said, they blamed jesus of blaspymy because he said he was the son of god."
	$Narrorator/AudioStreamPlayer7.play()


func _on_area_3d_4_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D41.global_position
	$AnimatableBody3D105/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "After that, The pharisies and sadusees sent Jesus to a roman goverer called ponchious pilate. He said 'Jesus did nothing worng', but The pharisies and sadusees kept shouting"
	$Narrorator/AudioStreamPlayer8.play()


func _on_area_3d_5_body_entered(body: player) -> void:
	body.global_position = $HTerrain2.global_position
	crusifiction()
	$CanvasLayer/TextEdit.text = "So Jesus got beaten up and had to carry his cross to the hill. "
	$Narrorator/AudioStreamPlayer10.play()

func crusifiction():
	$AnimatableBody3D111/AnimatableBody3D.play("move")
	$StaticBody3D46/AnimationPlayer.play("move")
	


func _on_area_3d_6_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D47/Marker3D.global_position
	$StaticBody3D53/AnimationPlayer.play("move")
	$AnimatableBody3D113/AnimationPlayer.play("move")
	$AnimatableBody3D112/AnimationPlayer.play("move")
	$AnimatableBody3D114/AnimationPlayer.play("move")
	$AnimatableBody3D117/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "Joseph loved jesus so much that he gave his tomb to Jesus. Ponchious Pilate put Guards to guard the tomb."
	$Narrorator/AudioStreamPlayer12.play()


func _on_animation_player_animation_finished(anim_name: StringName = "move") -> void:
	$AnimatableBody3D113.hide()


func _on_animation2_player_animation_finished(anim_name: StringName) -> void:
	$AnimatableBody3D112.hide()


func _on_animation3_player_animation_finished(anim_name: StringName) -> void:
	$AnimatableBody3D115.show()
	$AnimatableBody3D116.show()


func _on_area_3d_7_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D54.global_position
	$AnimatableBody3D118/AnimationPlayer2.play("move")
	$AnimatableBody3D119/AnimationPlayer2.play("move")
	set_active_environment($WorldEnvironment)
	$CanvasLayer/TextEdit.text = "The girls was rushing to tell the disiples that Jesus was alive, But then Jesus appered and said 'Dont be afraid.'"
	$Narrorator/AudioStreamPlayer14.play()

func set_active_environment(environment: WorldEnvironment):
	# Set the provided environment as the active environment
	get_viewport().world_3d.environment = environment.environment


func _on_area_3d_8_body_entered(body: AnimatableBody3D) -> void:
	set_active_environment($WorldEnvironment2)
	if body.is_in_group("jesus_emmaus"):
		$AnimatableBody3D121.hide()
		$AnimatableBody3D122.hide()
		$AnimatableBody3D123.hide()
	
	


func _on_area_3d_9_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D56/MeshInstance3D2.global_position
	$AnimatableBody3D122/AnimationPlayer.play("move")
	$AnimatableBody3D123/AnimationPlayer.play("move")
	$AnimatableBody3D121/AnimationPlayer.play("move")
	$CanvasLayer/TextEdit.text = "Later two disiples called simon and cleaopas were walking to a village called emmaus. Jesus came and said 'What are you talking about?', Cleaopas said what happened to Jesus but they did not reconise its Jesus."
	$Narrorator/AudioStreamPlayer15.play()


func _on_area_3d2_8_body_entered(body: player) -> void:
	$AnimatableBody3D126/AnimationPlayer.play("break_bread")
	$CanvasLayer/TextEdit.text = "When Jesus blessed them by breaking the bread in emmaus and giving it to them, they reconised Jesus, then Jesus vanished"
	$Narrorator/AudioStreamPlayer17.play()


func _on_area_3d_10_body_entered(body: Node3D) -> void:
	body.global_position = $StaticBody3D67.global_position
	set_active_environment($WorldEnvironment)
	$AnimatableBody3D137/AnimationPlayer.play("run")
	$AnimatableBody3D138/AnimationPlayer.play("run")
	$CanvasLayer/TextEdit.text = "Then they rushed to the other 10 disiples to tell that Jesus was alive!"
	$Narrorator/AudioStreamPlayer18.play()


func _on_area_3d_11_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D73.global_position
	$AnimatableBody3D150/AnimationPlayer.play("rise_to_heaven")
	$CanvasLayer/TextEdit.text = "Then the disiples saw that Jesus was alive, Jesus went up and up to heaven! THE END"
	$Narrorator/AudioStreamPlayer19.play()


func _on_area_3d_12_body_entered(body: player) -> void:
	Input.action_press("quit")
	


func _on_next_pressed() -> void:
	
	var timer = Timer.new()
	
	if $CanvasLayer/TextEdit.text == "Jesus and his disiples entered jurluselem. ":
		$CanvasLayer/TextEdit.text = "When Jesus entered, people was waving palm branches and said 'Hosanna, Hosanna, Hosanna in the name of the Lord'"
		$Narrorator/AudioStreamPlayer2.play()
		
			
	if $CanvasLayer/TextEdit.text == "Later, on the night, Jesus was having a passover meal with his disiples.":
		$CanvasLayer/TextEdit.text = "Jesus said 'One of you is going to betray me', Jesus' disiples wanted to know who could it be?. Jesus gave the bread to the one who was going to betray him"
		$Narrorator/AudioStreamPlayer4.play()
		
	
	if $CanvasLayer/TextEdit.text == "Jesus went to a garden to pray.":
		$CanvasLayer/TextEdit.text = "After Jesus finished praying , Judas(One of Jesus' disiples) Led the pharisies and sadusees to Jesus. The pharisies and sadusees arrested Jesus."
		$Narrorator/AudioStreamPlayer6.play()
	if $CanvasLayer/TextEdit.text == "After that, The pharisies and sadusees sent Jesus to a roman goverer called ponchious pilate. He said 'Jesus did nothing worng', but The pharisies and sadusees kept shouting":
		$CanvasLayer/TextEdit.text = "So he sent Jesus to be crusified on a cross."
		$Narrorator/AudioStreamPlayer9.play()
	if $CanvasLayer/TextEdit.text == "So Jesus got beaten up and had to carry his cross to the hill. ":
		$CanvasLayer/TextEdit.text = "Jesus went on the cross and they nailed him on the cross. Jesus said 'Please fogive them, they dont know what they are doing'"
		$Narrorator/AudioStreamPlayer11.play()
	if $CanvasLayer/TextEdit.text == "Joseph loved jesus so much that he gave his tomb to Jesus. Ponchious Pilate put Guards to guard the tomb.":
		$CanvasLayer/TextEdit.text = "Two of two Jesus' friends who were girls came to put spices on Jesus, but they saw that Jesus was gone and the Guards were laying down. An angel said 'Dont worry, Jesus has ressurected from the dead.'"
		$Narrorator/AudioStreamPlayer13.play()
	if $CanvasLayer/TextEdit.text == "Later two disiples called simon and cleaopas were walking to a village called emmaus. Jesus came and said 'What are you talking about?', Cleaopas said what happened to Jesus but they did not reconise its Jesus.":
		$CanvasLayer/TextEdit.text = "Jesus said 'You foolish! Havent you heard what the scriptures said,' and when they were nealy there Jesus went another way so they begged him to come because it was nearly night time."
		$Narrorator/AudioStreamPlayer16.play()





func _on_area_3d_13_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D23/Marker3D.global_position
	print(1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15 + 16 + 17 + 18 + 19 + 20 + 21 + 22 + 23 + 24 + 25 + 26 + 27 + 28 + 29 + 30 + 31 + 32 + 33 + 34 + 35 + 36 + 37 + 38 + 39 + 40 + 41 + 42 + 43 + 44 + 45 + 46 + 47 + 48 + 49 + 50)


func _on_area_3d_14_body_entered(body: player) -> void:
	body.global_position = Vector3(0, 0, 0)

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		# If the request was successful and the HTTP status code is 200 (OK).
		
		# Convert the raw byte array body to a UTF-8 string.
		# .strip_edges() removes any leading/trailing whitespace (like newlines).
		var public_ip = body.get_string_from_utf8().strip_edges()
		
		print("Public WAN IPv4 Address: " + public_ip)
		public_ip_label.text = "(Use after port forwarding)Public WAN IPv4 Address: " + public_ip # Update the UI label
	else:
		# If the request failed or returned a non-200 status code.
		print("Failed to get public IP.")
		
		print("HTTP Response Code: ", response_code) # HTTP status code
		public_ip_label.text = "Error: Could not get public IP."
		
		# You might want to add more specific error handling here based on result and response_code.
		# For example:
		# if result == HTTPRequest.RESULT_CANT_RESOLVE:
		#     print("Error: Could not resolve host (no internet connection or DNS issue).")
		# if response_code == 404:
		#     print("Error: Service URL not found.")

func _on_button_pressed() -> void:
	msg_rec.rpc(user, $CanvasLayer/Chat/LineEdit.text)
	print("\n" + user + ":" + $CanvasLayer/Chat/LineEdit.text)

@rpc("any_peer", "call_local")
func msg_rec(user: String, msg: String) -> void:
	$CanvasLayer/Chat.text += str("\n" + user + ":" + msg)
	

@rpc("any_peer", "call_local")
func msg_join(name: String) -> void:
	$CanvasLayer/Chat.text += str(name + " joined the game")
	


func _on_timer_timeout() -> void:
	msg_join.rpc(str("\n" + user))

@rpc("any_peer", "call_remote", "reliable")
func save_pos_on_server(pos: Vector3, namer: String) -> void:
	var Exepath = OS.get_executable_path().get_base_dir()
	# Double check: Only the server should execute this file logic
	if dedserver == true:
		var path = Exepath + "/data/Player/location/" + namer + ".save"
		var posav = FileAccess.open(path, FileAccess.WRITE)
		
		if posav:
			posav.store_var(pos)
			

@rpc("any_peer", "call_remote", "reliable")
func teleport_player(sender_id, new_position):
	# This runs on the client side
	get_node(str(sender_id)).global_position = new_position
	print("Teleported to: ", new_position)


@rpc("any_peer", "call_remote", "reliable")
func load_pos_on_server(namer: String):
	if not dedserver: return # Safety check
	
	var path = OS.get_executable_path().get_base_dir() + "/data/Player/location/" + namer + ".save"
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var saved_pos = file.get_var(true) # Assuming this is a Vector3 or Vector2
		file.close()
		
		# Find who asked for this and tell THEM to teleport
		var sender_id = multiplayer.get_remote_sender_id()
		teleport_player.rpc(sender_id, saved_pos)


func _on_area_3d_15_body_entered(body: player, namer: String = str(user)) -> void:
	load_pos_on_server.rpc_id(1, user)
	$Area3D15/CollisionShape3D.disabled = true

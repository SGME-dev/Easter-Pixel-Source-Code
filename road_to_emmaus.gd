extends Node3D

class_name road_to_emmaus

var effect
var recording

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var http_request: HTTPRequest = $CanvasLayer/HTTPRequest
@onready var lan_ip_label: Label = $CanvasLayer/Label
@onready var public_ip_label: Label = $CanvasLayer/Label2
var actual_port: int = 15780
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
var MAX_CONNECTIONS: int = 20
var user = FileAccess.open("user://username.save", FileAccess.READ).get_line()
@export var dedserver: bool = false
var ip: String

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
var tar = false
func is_dedicated_server():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--headless":
			return true
	return false

@rpc("any_peer", "call_local", "unreliable")
func send_rec_data(rec_data):
	var sample = AudioStreamWAV.new()
	sample.data = rec_data
	sample.format = AudioStreamWAV.FORMAT_16_BITS
	sample.mix_rate = AudioServer.get_mix_rate()*2
	$AudioStreamPlayer.stream = sample
	$AudioStreamPlayer.play()
	print("Received audio packet of size: ", rec_data.size())

func _on_send_recording_timer_timeout():
	var rec = effect.get_recording()
	if rec != null:
		# The line below only works if you are connected to a server
		if multiplayer.multiplayer_peer != null:
			rpc("send_rec_data", rec.data)
	if multiplayer.multiplayer_peer != null:
		if multiplayer.get_peers().size() > 0:
			recording = effect.get_recording()
			effect.set_recording_active(false)
			rpc("send_rec_data",recording.data)
			effect.set_recording_active(true)


func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Started the server...")
		_on_host_pressed()
		%host.hide()
		%join.hide()
		%LineEdit.hide()
		%LineEdit2.hide()
		$Sprite3D38.hide()
		$CanvasLayer/Panel.hide()
		dedserver = true
		var path = OS.get_executable_path().get_base_dir() + "max_players.limit"
		
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var player_limit = file.get_line()
			file.close()
			if int(player_limit) > 0 and int(player_limit) < 101:
				MAX_CONNECTIONS = int(player_limit)
	if !OS.has_feature("dedicated_server"):
		var idx = AudioServer.get_bus_index("record")
		effect = AudioServer.get_bus_effect(idx,0)
		print(effect)
		effect.set_recording_active(true)
		get_tree().set_auto_accept_quit(false)

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
	msg_leave.rpc(str("\n" + user))



func del_player(id: int) -> void:
	rpc("_del_player" ,id)
	
@rpc("any_peer","call_local")
func  _del_player(id: int) -> void:
	get_node(str(id)).queue_free()
	

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null



func set_active_environment(environment: WorldEnvironment):
	# Set the provided environment as the active environment
	get_viewport().world_3d.environment = environment.environment


func _on_next_pressed() -> void:
	$AnimatableBody3D121/speech.show()
	$AnimatableBody3D122/speech.hide()
	$CanvasLayer/Next.hide()
	$CanvasLayer/Next2.show()


func _on_next_2_pressed() -> void:
	$AnimatableBody3D121/speech.hide()
	$AnimatableBody3D122/speech2.show()
	$CanvasLayer/Next2.hide()
	$CanvasLayer/Next3.show()


func _on_next_3_pressed() -> void:
	$AnimatableBody3D122/speech2.hide()
	$AnimatableBody3D121/speech2.show()
	$CanvasLayer/Next3.hide()
	$CanvasLayer/Next4.show()


func _on_next_4_pressed() -> void:
	$AnimatableBody3D123.show()
	$AnimatableBody3D123/AnimationPlayer.play("move")
	$AnimatableBody3D121/speech2.hide()
	$AnimatableBody3D123/speech.show()
	$CanvasLayer/Next4.hide()
	$CanvasLayer/Next5.show()


func _on_next_5_pressed() -> void:
	
	
	$AnimatableBody3D123/speech.hide()
	$AnimatableBody3D122/speech3.show()
	$CanvasLayer/Next5.hide()
	$CanvasLayer/Next6.show()


func _on_next_6_pressed() -> void:
	$AnimatableBody3D122/speech3.hide()
	$AnimatableBody3D123/speech2.show()
	$CanvasLayer/Next6.hide()
	$CanvasLayer/Next7.show()


func _on_next_7_pressed() -> void:
	$AnimatableBody3D123/speech2.hide()
	$AnimatableBody3D121/speech3.show()
	$CanvasLayer/Next7.hide()
	$CanvasLayer/Next8.show()


func _on_next_8_pressed() -> void:
	$AnimatableBody3D121/speech3.hide()
	$AnimatableBody3D122/speech4.show()
	$CanvasLayer/Next8.hide()
	$CanvasLayer/Next9.show()



func _on_next_9_pressed() -> void:
	$AnimatableBody3D122/speech4.hide()
	$AnimatableBody3D121/speech4.show()
	$CanvasLayer/Next9.hide()
	$CanvasLayer/Next10.show()


func _on_next_10_pressed() -> void:
	$AnimatableBody3D121/speech4.hide()
	$AnimatableBody3D122/speech5.show()
	$CanvasLayer/Next10.hide()
	$CanvasLayer/Next11.show()


func _on_next_11_pressed() -> void:
	$AnimatableBody3D122/speech5.hide()
	$AnimatableBody3D121/speech5.show()
	$CanvasLayer/Next11.hide()
	$CanvasLayer/Next12.show()


func _on_next_12_pressed() -> void:
	$AnimatableBody3D121/speech5.hide()
	$AnimatableBody3D123/speech3.show()
	$CanvasLayer/Next12.hide()
	$CanvasLayer/Next13.show()


func _on_next_13_pressed() -> void:
	set_active_environment($WorldEnvironment2)
	$Sprite3D.show()
	$AnimatableBody3D123/speech3.hide()
	$AnimatableBody3D122/speech6.show()
	$CanvasLayer/Next13.hide()
	$CanvasLayer/Next14.show()


func _on_next_14_pressed() -> void:
	
	$AnimatableBody3D122/speech6.hide()
	$AnimatableBody3D121/speech6.show()
	$CanvasLayer/Next14.hide()
	$CanvasLayer/Next15.show()


func _on_next_15_pressed() -> void:
	$AnimatableBody3D121/speech6.hide()
	$AnimatableBody3D123/speech4.show()
	$CanvasLayer/Next15.hide()
	$CanvasLayer/Next16.show()
	$StaticBody3D/CollisionShape3D.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D2.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D3.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D4.set_deferred("disabled", true)
	$StaticBody3D/CollisionShape3D5.set_deferred("disabled", true)
	$StaticBody3D/Sprite3D.show()
	$StaticBody3D/Sprite3D2.show()
	$StaticBody3D/Sprite3D3.show()
	$StaticBody3D/Sprite3D4.show()
	$CanvasLayer/TextEdit.show()


func _on_next_16_pressed() -> void:
	if tar == true:
		$AnimatableBody3D126/AnimationPlayer.play("move")
		$CanvasLayer/Next16.hide()
		$CanvasLayer/Next17.show()


func _on_area_3d_body_entered(body: player) -> void:
	body.global_position = $StaticBody3D61.global_position


func _on_next_17_pressed() -> void:
	Input.action_press("quit")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimatableBody3D126.hide()
	$AnimatableBody3D125/Sprite3D2.show()
	$AnimatableBody3D125/Sprite3D.hide()
	$AnimatableBody3D124/Sprite3D.hide()
	$AnimatableBody3D124/Sprite3D2.show()


func _on_area_3d_2_body_entered(body: player) -> void:
	tar = true


func _on_button_pressed() -> void:
	$CanvasLayer/TextEdit/Label.text = "Right"
	$CanvasLayer/TextEdit/Timer.start()


func _on_button_2_pressed() -> void:
	$CanvasLayer/TextEdit/Label.text = "WROUNG"
	$CanvasLayer/TextEdit/Timer.start()


func _on_timer_timeout() -> void:
	$CanvasLayer/TextEdit.hide()

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

func _on_buttons_pressed() -> void:
	msg_rec.rpc(user, $CanvasLayer/Chat/LineEdit.text)
	

@rpc("any_peer", "call_local")
func msg_rec(user: String, msg: String) -> void:
	$CanvasLayer/Chat.text += str("\n" + user + ":" + msg)
	print("\n" + user + ":" + $CanvasLayer/Chat/LineEdit.text)

@rpc("any_peer", "call_local")
func msg_join(name: String) -> void:
	$CanvasLayer/Chat.text += str(name + " joined the game")
	print(name + " joined the game")

@rpc("any_peer", "call_local")
func msg_leave(name: String) -> void:
	$CanvasLayer/Chat.text += str(name + " left the game")
	print(name + " left the game")


func _on_timer_timeout2() -> void:
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
	$Area3D15/CollisionShape3D.queue_free()

@rpc("any_peer", "call_remote", "reliable")
func save_bans_on_server(namer: String) -> void:
	var Exepath = OS.get_executable_path().get_base_dir()
	# Double check: Only the server should execute this file logic
	if dedserver == true:
		var path = Exepath + "/data/bans/bans.txt"
		var bans = FileAccess.open(path, FileAccess.READ_WRITE)
		var nbans = bans.get_as_text()
		bans.store_string(nbans + "\n" + namer)
		

@rpc("any_peer", "call_remote", "reliable")
func save_ban_ips_on_server(namer: String) -> void:
	var Exepath = OS.get_executable_path().get_base_dir()
	# Double check: Only the server should execute this file logic
	if dedserver == true:
		var path = Exepath + "/data/ban-ips/ban-ips.txt"
		var bans = FileAccess.open(path, FileAccess.READ_WRITE)
		var nbans = bans.get_as_text()
		bans.store_string(nbans + "\n" + namer)
		

@rpc("any_peer", "call_remote", "reliable")
func load_bans_on_server():
	if not dedserver: return # Safety check
	
	var path = OS.get_executable_path().get_base_dir() + "/data/bans/bans.txt"
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var saved_bans = file.get_as_text()
		file.close()
		
		
		var sender_id = multiplayer.get_remote_sender_id()
		if user in saved_bans:
			exit_game(sender_id)

@rpc("any_peer", "call_remote", "reliable")
func load_ban_ips_on_server():
	if not dedserver: return # Safety check
	
	var path = OS.get_executable_path().get_base_dir() + "/data/ban-ips/ban-ips.txt"
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var saved_bans = file.get_as_text()
		file.close()
		
		
		var sender_id = multiplayer.get_remote_sender_id()
		$CanvasLayer/HTTPRequest2.request("https://ipv4.icanhazip.com")
		if ip in saved_bans:
			exit_game(sender_id)

func _on_ban_pressed() -> void:
	save_bans_on_server.rpc_id(1, $CanvasLayer/ban.text)


func _on_banip_pressed() -> void:
	save_ban_ips_on_server.rpc_id(1, $"CanvasLayer/ban-ip".text)


func _on_http_request_2_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if !OS.has_feature("dedicated_server"):
		if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
			# If the request was successful and the HTTP status code is 200 (OK).
			
			# Convert the raw byte array body to a UTF-8 string.
			# .strip_edges() removes any leading/trailing whitespace (like newlines).
			var public_ip = body.get_string_from_utf8().strip_edges()
			
			print("Public WAN IPv4 Address: " + public_ip)
			ip = public_ip
		else:
			# If the request failed or returned a non-200 status code.
			print("Failed to get public IP.")
			
			print("HTTP Response Code: ", response_code) # HTTP status code
			
			
			# You might want to add more specific error handling here based on result and response_code.
			# For example:
			# if result == HTTPRequest.RESULT_CANT_RESOLVE:
			#     print("Error: Could not resolve host (no internet connection or DNS issue).")
			# if response_code == 404:
			#     print("Error: Service URL not found.")
			

extends Node3D

class_name easteregghunt

@onready var label_3: TextEdit = $Label3

@onready var http_request: HTTPRequest = $CanvasLayer/HTTPRequest
@onready var lan_ip_label: Label = $CanvasLayer/Label
@onready var public_ip_label: Label = $CanvasLayer/Label2
@export var easter_egg: int = 0
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
var MAX_CONNECTIONS: int = 20
var user = FileAccess.open("user://username.save", FileAccess.READ).get_line()
@export var dedserver: bool = false
var ip: String

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func is_dedicated_server():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--headless":
			return true
	return false

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

func _physics_process(delta: float) -> void:
	if easter_egg == 12:
		$Label.text = "Go to the electricity sound!"
	$Label2.text = str(easter_egg, "/12")

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


func _on_join_pressed(address: String = str(%LineEdit.text)) -> void:
	if address.is_empty() or address == "localhost":
		address = DEFAULT_SERVER_IP
	if %LineEdit2.text.is_empty():
		%LineEdit2.text = port
	peer.create_client(address, int(%LineEdit2.text))
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


func _on_area_3d_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 1:\nMatthew 21:9: And the crowds that went before him and that followed him were shouting, “Hosanna to the Son of David! Blessed is he who comes in the name of the Lord! Hosanna in the highest!”\nPoem:\nPalm branches wave, a joyful sound,\n'Hosanna!' echoes all around.\nThe King arrives, on humble beast,\nA blessing comes, from West to East."
	$Area3D.hide()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_2_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 2:\nJohn 12:13: so they took branches of palm trees and went out to meet him, crying out, “Hosanna! Blessed is he who comes in the name of the Lord, even the King of Israel!”\nPoem:\nWith verdant fronds, they pave the way,\nFor Israel's King, this glorious day.\n'Hosanna!' rings, a heartfelt plea,\nFor the promised one, for all to see."
	$Area3D2.hide()
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_3_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 3:\nMatthew 26:26: Now as they were eating, Jesus took bread, and after blessing it broke it and gave it to the disciples, and said, “Take, eat; this is my body.”\nPoem:\nThe loaf He held, a symbol true,\nMy body broken, given for you.\nA sacred meal, a love profound,\nWhere grace and sacrifice are found."
	$Area3D3.hide()
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1
	


func _on_area_3d_4_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 4:\nJohn 13:34: A new commandment I give to you, that you love one another: just as I have loved you, you also are to love one another.\nPoem:\nA bond He forged, with gentle plea,\nLove one another, even as Me.\nA testament of heart and hand,\nA love that all may understand."
	$Area3D4.hide()
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_5_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 5:\nMatthew 26:39: And going a little farther he fell on his face and prayed, saying, “My Father, if it be possible, let this cup pass from me; nevertheless, not as I will, but as you will.”\nPoem:\nBeneath the olives, sorrow deep,\nA Father's will, His heart to keep.\nThe cup of suffering, bitter cost,\nYet Your will, not mine, though all seems lost."
	$Area3D5.hide()
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_6_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 6:\nLuke 22:42: saying, “Father, if you are willing, remove this cup from me. Nevertheless, not my will, but yours, be done.”\nPoem:\nIn fervent prayer, He sought release,\nBut bowed His head to perfect peace.\nA humble spirit, strong and true,\nYour way, O Father, I pursue."
	$Area3D6.hide()
	$Area3D6/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_7_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 7:\nMatthew 27:22: Pilate said to them, “Then what should I do with Jesus who is called Christ?” They all said, “Let him be crucified!”\nPoem:\nA question asked, a choice to make,\nBut cries of anger, hearts that break.\n'Crucify Him!' the voices roar,\nAnd darkness falls, forevermore."
	$Area3D7.hide()
	$Area3D7/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1

func _on_area_3d_8_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 8:\nJohn 19:30: When Jesus had received the sour wine, he said, “It is finished,” and he bowed his head and gave up his spirit.\nPoem:\nThe bitter draught, His final taste,\nIt is finished, no time to waste.\nHe yields His breath, His earthly fight,\nAnd darkness claims the fading light."
	$Area3D8.hide()
	$Area3D8/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_9_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 9:\nMatthew 28:5: But the angel said to the women, “Do not be afraid, for I know that you seek Jesus who was crucified.\nPoem:\nWith hearts of sorrow, they draw near,\nBut angel words dispel all fear.\n'He is not here,' the message bright,\nThe crucified, now filled with light."
	$Area3D9.hide()
	$Area3D9/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_10_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 10:\nLuke 24:6: He is not here, but has risen.\nPoem:\nThe tomb is empty, stone aside,\nDeath's power broken, cast aside.\nA simple truth, a glorious claim,\nHe has arisen, praise His name!"
	$Area3D10.hide()
	$Area3D10/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_11_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 11:\nLuke 24:15: As they talked and discussed these things with each other, Jesus himself came up and walked along with them; but they were kept from recognizing him.\nPoem:\nAlong the road, with heavy tread,\nThey spoke of loss, their hopes all dead.\nAnd Jesus walked, though eyes were dim,\nA stranger near, unknown to them."
	$Area3D11.hide()
	$Area3D11/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_12_body_entered(body: player) -> void:
	label_3.show()
	label_3.text += "\nEaster egg 12:\nLuke 24:31: Then their eyes were opened and they recognized him, and he disappeared from their sight.\nPoem:\nThe bread He broke, a familiar sign,\nTheir opened eyes, a truth divine.\nThey knew Him then, their risen Lord,\nBefore He vanished at His word."
	$Area3D12.hide()
	$Area3D12/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_13_body_entered(body: player) -> void:
	if easter_egg == 12:
		Input.action_press("quit")
	else:
		body.label_2.text = "Collect all 12 easter eggs!"
		body.label_2.show()

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
			

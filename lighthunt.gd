extends Node3D

class_name lighthunt
@onready var label_3: TextEdit = $Label3
@onready var http_request: HTTPRequest = $CanvasLayer/HTTPRequest
@onready var lan_ip_label: Label = $CanvasLayer/Label
@onready var public_ip_label: Label = $CanvasLayer/Label2
@export var lights: int = 0
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
	$Label2.text = str(lights, "/21")
	

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
		%LineEdit2.text = str(port)
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





func _on_area_3d_6_body_entered(body: player) -> void:
	if lights == 21 or lights >= 21:
		get_tree().quit()
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
			


func _on_area_3d_body_entered(body: player) -> void:
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	$Area3D.hide()
	$Label3.show()
	lights += 1
	$Label3.text += "\nMatthew 4:17: From that time Jesus began to preach, and to say, Repent: for the kingdom of heaven is at hand."


func _on_area_3d_2_body_entered(body: player) -> void:
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	$Area3D2.hide()
	$Label3.show()
	$Label3.text += "\nJohn 2:11: This beginning of miracles did Jesus in Cana of Galilee, and manifested forth his glory; and his disciples believed on him."
	lights += 1

func _on_area_3d_3_body_entered(body: player) -> void:
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	$Area3D3.hide()
	$Label3.show()
	$Label3.text += "\nMark 1:17: And Jesus said unto them, Come ye after me, and I will make you to become fishers of men."
	lights += 1

func _on_area_3d_4_body_entered(body: player) -> void:
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	$Area3D4.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 5:3: Blessed are the poor in spirit: for theirs is the kingdom of heaven."
	lights += 1

func _on_area_3d_5_body_entered(body: player) -> void:
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	$Area3D5.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 5:14: Ye are the light of the world. A city that is set on an hill cannot be hid."
	lights += 1


func _on_area_3d_7_body_entered(body: player) -> void:
	$Area3D7/CollisionShape3D.set_deferred("disabled", true)
	$Area3D7.hide()
	$Label3.show()
	$Label3.text += "\nJohn 6:35: And Jesus said unto them, I am the bread of life: he that cometh to me shall never hunger."
	lights += 1

func _on_area_3d_8_body_entered(body: player) -> void:
	$Area3D8/CollisionShape3D.set_deferred("disabled", true)
	$Area3D8.hide()
	$Label3.show()
	$Label3.text += "\nJohn 8:12: Then spake Jesus again unto them, saying, I am the light of the world: he that followeth me shall not walk in darkness."
	lights += 1

func _on_area_3d_9_body_entered(body: player) -> void:
	$Area3D9/CollisionShape3D.set_deferred("disabled", true)
	$Area3D9.hide()
	$Label3.show()
	$Label3.text += "\nJohn 10:11: I am the good shepherd: the good shepherd giveth his life for the sheep."
	lights += 1

func _on_area_3d_10_body_entered(body: player) -> void:
	$Area3D10/CollisionShape3D.set_deferred("disabled", true)
	$Area3D10.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 11:28: Come unto me, all ye that labour and are heavy laden, and I will give you rest."
	lights += 1

func _on_area_3d_11_body_entered(body: player) -> void:
	$Area3D11/CollisionShape3D.set_deferred("disabled", true)
	$Area3D11.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 19:14: But Jesus said, Suffer little children, and forbid them not, to come unto me: for of such is the kingdom of heaven."
	lights += 1


func _on_area_3d_12_body_entered(body: player) -> void:
	$Area3D12/CollisionShape3D.set_deferred("disabled", true)
	$Area3D12.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 22:39: And the second is like unto it, Thou shalt love thy neighbour as thyself."
	lights += 1

func _on_area_3d_13_body_entered(body: player) -> void:
	$Area3D13/CollisionShape3D.set_deferred("disabled", true)
	$Area3D13.hide()
	$Label3.show()
	$Label3.text += "\nMark 10:27: And Jesus looking upon them saith, With men it is impossible, but not with God: for with God all things are possible."
	lights += 1

func _on_area_3d_14_body_entered(body: player) -> void:
	$Area3D14/CollisionShape3D.set_deferred("disabled", true)
	$Area3D14.hide()
	$Label3.show()
	$Label3.text += "\nLuke 6:31: And as ye would that men should do to you, do ye also to them likewise."
	lights += 1


func _on_area_3d_16_body_entered(body: player) -> void:
	$Area3D16/CollisionShape3D.set_deferred("disabled", true)
	$Area3D16.hide()
	$Label3.show()
	$Label3.text += "\nLuke 19:10: For the Son of man is come to seek and to save that which was lost."
	lights += 1


func _on_area_3d_17_body_entered(body: player) -> void:
	$Area3D17/CollisionShape3D.set_deferred("disabled", true)
	$Area3D17.hide()
	$Label3.show()
	$Label3.text += "\nJohn 13:34: A new commandment I give unto you, That ye love one another; as I have loved you, that ye also love one another."
	lights += 1


func _on_area_3d_18_body_entered(body: player) -> void:
	$Area3D18/CollisionShape3D.set_deferred("disabled", true)
	$Area3D18.hide()
	$Label3.show()
	$Label3.text += "\nLuke 22:42: Saying, Father, if thou be willing, remove this cup from me: nevertheless not my will, but thine, be done."
	lights += 1


func _on_area_3d_19_body_entered(body: player) -> void:
	$Area3D19/CollisionShape3D.set_deferred("disabled", true)
	$Area3D19.hide()
	$Label3.show()
	$Label3.text += "\nLuke 23:34: Then said Jesus, Father, forgive them; for they know not what they do."
	lights += 1


func _on_area_3d_20_body_entered(body: player) -> void:
	$Area3D20/CollisionShape3D.set_deferred("disabled", true)
	$Area3D20.hide()
	$Label3.show()
	$Label3.text += "\nJohn 15:13: Greater love hath no man than this, that a man lay down his life for his friends."
	lights += 1


func _on_area_3d_21_body_entered(body: player) -> void:
	$Area3D21/CollisionShape3D.set_deferred("disabled", true)
	$Area3D21.hide()
	$Label3.show()
	$Label3.text += "\nJohn 19:30: When Jesus therefore had received the vinegar, he said, It is finished: and he bowed his head, and gave up the ghost."
	lights += 1


func _on_area_3d_22_body_entered(body: player) -> void:
	$Area3D22/CollisionShape3D.set_deferred("disabled", true)
	$Area3D22.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 28:6: He is not here: for he is risen, as he said. Come, see the place where the Lord lay."
	lights += 1


func _on_area_3d_23_body_entered(body: player) -> void:
	$Area3D23/CollisionShape3D.set_deferred("disabled", true)
	$Area3D23.hide()
	$Label3.show()
	$Label3.text += "\nMatthew 28:19: Go ye therefore, and teach all nations, baptizing them in the name of the Father, and of the Son, and of the Holy Ghost."
	lights += 1


func _on_area_3d_24_body_entered(body: player) -> void:
	body.global_position = Vector3(0, 0, 0)

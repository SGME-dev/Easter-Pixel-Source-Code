extends Node3D

class_name easteregghunt_resurect

@onready var label_3: TextEdit = $Label3
@onready var http_request: HTTPRequest = $CanvasLayer/HTTPRequest
@onready var lan_ip_label: Label = $CanvasLayer/Label
@onready var public_ip_label: Label = $CanvasLayer/Label2
@export var easter_egg: int = 0
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 20
var user = FileAccess.open("user://username.save", FileAccess.READ).get_line()

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

func _physics_process(delta: float) -> void:
	if easter_egg >= 5:
		easter_egg = 5
	if easter_egg == 5:
		$Label.text = "Go to the top of the highest mountain"
		label_3.text = "Jesus died, rose, gave life."
	$Label2.text = str(easter_egg, "/5")
	if easter_egg == 1:
		label_3.text = "Jesus"
	if easter_egg == 2:
		label_3.text = "Jesus died"
	if easter_egg == 3:
		label_3.text = "Jesus died, rose "
	if easter_egg == 4:
		label_3.text = "Jesus died, rose, gave"
	

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


func del_player(id: int) -> void:
	rpc("_del_player" ,id)
	
@rpc("any_peer","call_local")
func  _del_player(id: int) -> void:
	get_node(str(id)).queue_free()
	

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null


func _on_area_3d_body_entered(body: player) -> void:
	label_3.show()
	$Area3D.hide()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_2_body_entered(body: player) -> void:
	label_3.show()
	$Area3D2.hide()
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_3_body_entered(body: player) -> void:
	label_3.show()
	$Area3D3.hide()
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1
	


func _on_area_3d_4_body_entered(body: player) -> void:
	label_3.show()
	$Area3D4.hide()
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_5_body_entered(body: player) -> void:
	label_3.show()
	$Area3D5.hide()
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	easter_egg += 1


func _on_area_3d_6_body_entered(body: Node3D) -> void:
	if easter_egg == 5 or easter_egg >= 5:
		Input.action_press("quit")

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

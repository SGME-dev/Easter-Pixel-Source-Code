extends Node3D

class_name lobby_bible_verses

@onready var lan_ip_label: Label = $CanvasLayer/Label
@onready var public_ip_label: Label = $CanvasLayer/Label2
@onready var http_request: HTTPRequest = $CanvasLayer/HTTPRequest
@onready var label: TextEdit = $Label
var port: int = 15780
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
var MAX_CONNECTIONS: int = 20
@export var bible_verses: int = 0
var user = FileAccess.open("user://username.save", FileAccess.READ).get_line()
@export var dedserver: bool = false
var ip: String

static var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func  _physics_process(delta: float) -> void:
	$Label2.text = str("50/" + str(bible_verses))

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
	label.text += "\nMatthew 21:9: 'And the crowds that went before him and that followed him were shouting, 'Hosanna to the Son of David! Blessed is he who comes in the name of the Lord! Hosanna in the highest!''"
	label.show()
	$Area3D/CollisionShape3D.set_deferred("disabled", true)
	$Area3D.hide()
	body.Area3d = $Area3D
	bible_verses += 1
	


func _on_area_3d_2_body_entered(body: player) -> void:
	label.text += "\nMark 11:9: And those who went before and those who followed were shouting, 'Hosanna! Blessed is he who comes in the name of the Lord!'"
	$Area3D2/CollisionShape3D.set_deferred("disabled", true)
	$Area3D2.hide()
	body.Area3d = $Area3D2
	bible_verses += 1

func _on_area_3d_3_body_entered(body: player) -> void:
	label.text += "\nMark 11:10: 'Blessed is the kingdom of our father David that is coming! Hosanna in the highest!'"
	$Area3D3/CollisionShape3D.set_deferred("disabled", true)
	$Area3D3.hide()
	body.Area3d = $Area3D3
	bible_verses += 1

func _on_area_3d_4_body_entered(body: player) -> void:
	label.text += "\nLuke 19:38: saying, “Blessed is the King who comes in the name of the Lord! Peace in heaven and glory in the highest!”"
	$Area3D4/CollisionShape3D.set_deferred("disabled", true)
	$Area3D4.hide()
	body.Area3d = $Area3D4
	bible_verses += 1

func _on_area_3d_5_body_entered(body: player) -> void:
	label.text += "\nJohn 12:13: so they took branches of palm trees and went out to meet him, crying out, “Hosanna! Blessed is he who comes in the name of the Lord, even the King of Israel!”"
	$Area3D5/CollisionShape3D.set_deferred("disabled", true)
	$Area3D5.hide()
	body.Area3d = $Area3D5
	bible_verses += 1

func _on_area_3d_6_body_entered(body: player) -> void:
	label.text += "\nMatthew 26:26: Now as they were eating, Jesus took bread, and after blessing it broke it and gave it to the disciples, and said, “Take, eat; this is my body.”"
	$Area3D6/CollisionShape3D.set_deferred("disabled", true)
	$Area3D6.hide()
	body.Area3d = $Area3D6
	bible_verses += 1

func _on_area_3d_7_body_entered(body: player) -> void:
	label.text += "\nMatthew 26:27: And he took a cup, and when he had given thanks he gave it to them, saying, “Drink of it, all of you,"
	$Area3D7/CollisionShape3D.set_deferred("disabled", true)
	$Area3D7.hide()
	body.Area3d = $Area3D7
	bible_verses += 1

func _on_area_3d_8_body_entered(body: player) -> void:
	label.text += "\nMatthew 26:28: for this is my blood of the covenant, which is poured out for many for the forgiveness of sins.”"
	$Area3D8/CollisionShape3D.set_deferred("disabled", true)
	$Area3D8.hide()
	body.Area3d = $Area3D8
	bible_verses += 1



func _on_area_3d_10_body_entered(body: player) -> void:
	label.text += "\nLuke 22:20: And likewise the cup after they had eaten, saying, “This cup that is poured out for you is the new covenant in my blood, which is poured out for you."
	$Area3D10/CollisionShape3D.set_deferred("disabled", true)
	$Area3D10.hide()
	body.Area3d = $Area3D10
	bible_verses += 1

func _on_area_3d_11_body_entered(body: player) -> void:
	label.text += "\nJohn 13:34: A new commandment I give to you, that you love one another: just as I have loved you, you also are to love one another." 
	$Area3D11/CollisionShape3D.set_deferred("disabled", true)
	$Area3D11.hide()
	body.Area3d = $Area3D11
	bible_verses += 1

func _on_area_3d_12_body_entered(body: player) -> void:
	label.text += "\nJohn 13:35: By this all people will know that you are my disciples, if you have love for one another.”"
	$Area3D12/CollisionShape3D.set_deferred("disabled", true)
	$Area3D12.hide()
	body.Area3d = $Area3D12
	bible_verses += 1

func _on_laser_3d_body_entered(body: player) -> void:
	body.global_position = Vector3(0, 0, 0)


func _on_area_3d_13_body_entered(body: player) -> void:
	label.text += "\n Matthew 26:39: And going a little farther he fell on his face and prayed, saying, “My Father, if it be possible, let this cup pass from me; nevertheless, not as I will, but as you will.”"  
	$Area3D13/CollisionShape3D.set_deferred("disabled", true)
	$Area3D13.hide()
	body.Area3d = $Area3D13
	bible_verses += 1

func _on_area_3d_14_body_entered(body: player) -> void:
	label.text += "\nMark 14:36: And he said, “Abba, Father, all things are possible for you. Remove this cup from me. Yet not what I will, but what you will.”"  
	$Area3D14/CollisionShape3D.set_deferred("disabled", true)
	$Area3D14.hide()
	body.Area3d = $Area3D14
	bible_verses += 1

func _on_area_3d_15_body_entered(body: player) -> void:
	label.text += "\nLuke 22:42: saying, “Father, if you are willing, remove this cup from me. Nevertheless, not my will, but yours, be done.”"
	$Area3D15/CollisionShape3D.set_deferred("disabled", true)
	$Area3D15.hide()
	body.Area3d = $Area3D15
	bible_verses += 1

func _on_area_3d_16_body_entered(body: player) -> void:
	label.text += "\nJohn 18:11: So Jesus said to Peter, “Put your sword into its sheath; shall I not drink the cup that the Father has given me?”"  
	$Area3D16/CollisionShape3D.set_deferred("disabled", true)
	$Area3D16.hide()
	body.Area3d = $Area3D16
	bible_verses += 1

func _on_area_3d_17_body_entered(body: player) -> void:
	label.text += "\nMatthew 27:22: Pilate said to them, “Then what should I do with Jesus who is called Christ?” They all said, “Let him be crucified!”"
	$Area3D17/CollisionShape3D.set_deferred("disabled", true)
	$Area3D17.hide()
	body.Area3d = $Area3D17
	bible_verses += 1

func _on_area_3d_18_body_entered(body: player) -> void:
	label.text += "\nMatthew 27:23: And he said, “Why? What evil has he done?” But they shouted all the more, “Let him be crucified!”"
	$Area3D18/CollisionShape3D.set_deferred("disabled", true)
	$Area3D18.hide()
	body.Area3d = $Area3D18
	bible_verses += 1

func _on_area_3d_19_body_entered(body: player) -> void:
	label.text += "\nMark 15:25: And it was the third hour when they crucified him."
	$Area3D19/CollisionShape3D.set_deferred("disabled", true)
	$Area3D19.hide()
	body.Area3d = $Area3D19
	bible_verses += 1


func _on_area_3d_20_body_entered(body: player) -> void:
	label.text += "\nLuke 23:34: And Jesus said, “Father, forgive them, for they know not what they do.” And they cast lots to divide his garments." 
	$Area3D20/CollisionShape3D.set_deferred("disabled", true)
	$Area3D20.hide()
	body.Area3d = $Area3D20
	bible_verses += 1

func _on_area_3d_21_body_entered(body: player) -> void:
	label.text += "\nJohn 19:30: When Jesus had received the sour wine, he said, “It is finished,” and he bowed his head and gave up his spirit."  
	$Area3D21/CollisionShape3D.set_deferred("disabled", true)
	$Area3D21.hide()
	body.Area3d = $Area3D21
	bible_verses += 1

func _on_area_3d_22_body_entered(body: player) -> void:
	label.text += "\nMatthew 28:5: But the angel said to the women, Do not be afraid, for I know that you seek Jesus who was crucified.\nMatthew 28:6: He is not here, for he has risen, as he said. Come, see the place where he lay.\nMark 16:6: And he said to them, Do not be alarmed. You seek Jesus of Nazareth, who was crucified. He has risen; he is not here. See the place where they laid him.\nLuke 24:6: He is not here, but has risen.\nLuke 24:7: Remember how he told you, while he was still in Galilee, that the Son of Man must be delivered into the hands of sinful men and be crucified and on the third day rise.\nJohn 20:17: Jesus said to her, Do not cling to me, for I have not yet ascended to the Father; but go to my brothers and say to them, ‘I am ascending to my Father and your Father, to my God and your God.’\nLuke 24:13: Now that same day two of them were going to a village called Emmaus, about seven miles from Jerusalem.\nLuke 24:14: They were talking with each other about everything that had happened.\nLuke 24:15: As they talked and discussed these things with each other, Jesus himself came up and walked along with them; but they were kept from recognizing him.\nLuke 24:16: He asked them, “What are you discussing together as you walk along?”\nLuke 24:17: They stood still, their faces downcast. One of them, named Cleopas, asked him, “Are you the only one visiting Jerusalem who does not know the things that have happened there in these days?”\nLuke 24:18: “What things?” he asked.\nLuke 24:19: “About Jesus of Nazareth,” they replied. “He was a powerful prophet, powerful in word and deed before God and all the people. The chief priests and our rulers handed him over to be sentenced to death, and they crucified him;\nLuke 24:20: but we had hoped that he was the one who was going to redeem Israel. And what is more, it is now the third day since all this took place.\nLuke 24:21: In addition, some of our women amazed us. They went to the tomb early this morning but didn’t find his body. They came and told us that they had seen a vision of angels, who said he was alive.\nLuke 24:22: Then some of our companions went to the tomb and found it just as the women had said, but they did not see Jesus.”\nLuke 24:23: He said to them, “How foolish you are, and how slow to believe all that the prophets have spoken! Did not the Messiah have to suffer these things and then enter his glory?”\nLuke 24:24: And beginning with Moses and all the Prophets, he explained to them what was said in all the Scriptures concerning himself.\nLuke 24:25: As they approached the village to which they were going, Jesus continued on as if he were going farther.\nLuke 24:26: But they urged him strongly, “Stay with us, for it is nearly evening; the day is almost over.” So he went in to stay with them.\nLuke 24:27: When he was at the table with them, he took bread, gave thanks, broke it and began to give it to them.\nLuke 24:28: Then their eyes were opened and they recognized him, and he disappeared from their sight.\nLuke 24:29: They asked each other, “Were not our hearts burning within us while he talked with us on the road and opened the Scriptures to us?”\nLuke 24:30: They got up and returned at once to Jerusalem.\nLuke 24:31: Then they found the Eleven and those with them, assembled together and saying, “It is true! The Lord has risen and has appeared to Simon.”\nLuke 24:32: Then the two told what had happened on the way, and how Jesus was recognized by them when he broke the bread.\nLuke 24:33: They got up and returned at once to Jerusalem. Then they found the Eleven and those with them, assembled together and saying, “It is true! The Lord has risen and has appeared to Simon.”\nLuke 24:34: and saying, “It is true! The Lord has risen and has appeared to Simon.”\nLuke 24:35: Then the two told what had happened on the way, and how Jesus was recognized by them when he broke the bread.";
	$Area3D22/CollisionShape3D.set_deferred("disabled", true)
	$Area3D22.hide()
	body.Area3d = $Area3D22
	bible_verses += 29

func _on_area_3d_23_body_entered(body: player) -> void:
	 
	if label.get_line_count() == 51:
		$RichTextLabel.show()
		label.hide()
	else:
		body.label_2.text = "COLLECT ALL 50 BIBLE VERSES"
		body.global_position = Vector3(0, 0, 0)


func _on_area_3d_24_body_entered(body: player) -> void:
	if body.Area3d == null:
		body.global_position = Vector3(0, 0, 0)
	else:
		body.global_position = body.Area3d.global_position


func _on_button_pressed() -> void:
	Input.action_press("quit")


func _on_area_3d_9_body_entered(body: player) -> void:
	label.text += "\nLuke 22:19: And he took bread, and when he had given thanks, he broke it and gave it to them, saying, “This is my body, which is given for you. Do this in remembrance of me.”"  
	$Area3D9/CollisionShape3D.set_deferred("disabled", true)
	$Area3D9.hide()
	body.Area3d = $Area3D9
	bible_verses += 1

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
	print(user + " joined the game")

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




func _on_area_3d_15s_body_entered(body: player, namer: String = str(user)) -> void:
	load_pos_on_server.rpc_id(1, user)
	$Area3D15s/CollisionShape3D.queue_free()

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
			

extends Control

signal found_server # Emitted when a new server is found
signal server_removed # Emitted when a server is removed (not implemented in this version)
signal joinGame(ip) # Emitted when a 'Join' button is pressed on a server entry

var broadcastTimer : Timer
var RoomInfo = {"name":"name", "playerCount": 0} # Room info for broadcasting
var broadcaster : PacketPeerUDP
var listner : PacketPeerUDP

@export var listenPort : int = 15780
@export var broadcastPort : int = 15781
@export var broadcastAddress : String = '192.168.4.25'

@export var serverInfoScene : PackedScene # This should be set to your new server_info_item.tscn

# Dictionary to keep track of active servers by IP to prevent duplicates
# Key: Server IP (String), Value: Instance of serverInfoScene (Node)
var active_servers: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	broadcastTimer = $BroadcastTimer # Assumes BroadcastTimer is a child node
	setUp()

func setUp():
	listner = PacketPeerUDP.new()
	var ok = listner.bind(listenPort)

	if ok == OK:
		print("Bound to listen Port " + str(listenPort) + " Successful!")
		# Assumes Label2 is a child node
		if has_node("Label2"):
			$Label2.text="Bound To Listen Port: true"
	else:
		print("Failed to bind to listen port!")
		if has_node("Label2"):
			$Label2.text="Bound To Listen Port: false"

func setUpBroadCast(name: String):
	RoomInfo.name = name # Set the room name for broadcasting
	broadcaster = PacketPeerUDP.new()
	broadcaster.set_broadcast_enabled(true)
	broadcaster.set_dest_address(broadcastAddress, listenPort)

	var ok = broadcaster.bind(broadcastPort)

	if ok == OK:
		print("Bound to Broadcast Port " + str(broadcastPort) + " Successful!")
	else:
		print("Failed to bind to broadcast port!")

	$BroadcastTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Process all available packets in the listener queue
	while listner.get_available_packet_count() > 0:
		var server_ip = listner.get_packet_ip()
		var server_port = listner.get_packet_port() # Port is received but not used for display
		var bytes = listner.get_packet()
		var data_string = bytes.get_string_from_ascii()

		# Attempt to parse the incoming data as JSON
		var data_json = JSON.parse_string(data_string)
		if data_json == null:
			print("Received malformed JSON packet from " + server_ip)
			continue # Skip to the next packet

		var room_name = data_json.get("name", "Unknown Server") # Get room name, default if not found
		var player_count = data_json.get("playerCount", 0) # Get player count, default if not found

		print("Received broadcast from: " + server_ip + ":" + str(server_port) + " - Name: " + room_name + " Players: " + str(player_count))

		# Check if this server IP is already in our list of active servers
		if not active_servers.has(server_ip):
			# If it's a new server, instantiate the server info scene
			var current_info = serverInfoScene.instantiate()
			# Set the IP text in the instantiated scene's label
			current_info.set_ip(server_ip)
			# Connect the joinGame signal from the instantiated scene to our handler
			current_info.joinGame.connect(joinbyIp)

			# Add the new server entry to the VBoxContainer (assuming it's named Panel/VBoxContainer)
			if has_node("Panel/VBoxContainer"):
				$Panel/VBoxContainer.add_child(current_info)
				active_servers[server_ip] = current_info # Add to our tracking dictionary
				found_server.emit(server_ip, room_name, player_count) # Emit a signal for new server found

# Handler for the broadcast timer timeout
func _on_broadcast_timer_timeout():
	print("Broadcasting Game!")
	var data = JSON.stringify(RoomInfo) # Convert RoomInfo dictionary to JSON string
	var packet = data.to_ascii_buffer() # Convert string to byte array
	broadcaster.put_packet(packet) # Send the packet

# Clean up network resources when the node is removed
func cleanUp():
	if listner != null:
		listner.close()
	if broadcastTimer != null:
		broadcastTimer.stop()
	if broadcaster != null:
		broadcaster.close()

# Called when the node is about to be removed from the scene tree.
func _exit_tree():
	cleanUp()

# Handler for the joinGame signal emitted by a server info entry
func joinbyIp(ip: String):
	print("Attempting to join game at IP: " + ip)
	joinGame.emit(ip) # Re-emit this signal to the lobby script

extends Node3D

func _ready():
	print("--- Local (Private) IPv4 Addresses ---")
	var local_addresses = IP.get_local_addresses()
	
	var found_desired_ipv4 = false
	for address in local_addresses:
		# Filter for IPv4 addresses (IPv6 addresses will also be in the list)
		# IPv4 addresses typically don't contain colons.
		# We'll also prioritize common private network ranges for a "primary" local address.
		# Note: Godot's IP class doesn't directly expose interface types (Wi-Fi/Ethernet),
		# so this relies on common IP range conventions.
		if "." in address and ":" not in address:
			# Common private IPv4 ranges: 192.168.x.x, 10.x.x.x, 172.16.x.x - 172.31.x.x
			if address.begins_with("192.168.") or \
			   address.begins_with("10.") or \
			   (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				
				print("Found a likely primary Local IPv4 (e.g., Wi-Fi/Main LAN): " + address)
				found_desired_ipv4 = true
				break # Stop after finding the first suitable address
		# You can also print IPv6 if interested:
		# elif ":" in address:
		#     print("Local IPv6: " + address)

	if not found_desired_ipv4:
		print("No suitable local IPv4 address found (e.g., not in common private ranges).")
	if local_addresses.is_empty():
		print("No local addresses found at all.")

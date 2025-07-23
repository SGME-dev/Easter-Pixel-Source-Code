extends Control


signal joinGame(ip) # Signal to emit when the join button is pressed

@onready var ip_label = $IpLabel # Assumes a Label node named "IpLabel" as a child
@onready var join_button = $JoinButton # Assumes a Button node named "JoinButton" as a child

func _ready():
	# Connect the button's pressed signal to our internal handler
	join_button.pressed.connect(_on_join_button_pressed)

# Method to set the IP text for this server entry
func set_ip(ip_address: String):
	ip_label.text = ip_address

# Internal handler for the join button press
func _on_join_button_pressed():
	# Emit the joinGame signal with the IP address of this entry
	joinGame.emit(ip_label.text)

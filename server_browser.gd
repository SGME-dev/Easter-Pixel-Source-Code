extends Control

signal  found_server
signal  server_removed

signal joinGame(ip)
var broadcastTimer : Timer

func _ready():
	broadcastTimer = $BroadcastTimer
	pass # Replace with function body.


func _on_broadcast_timer_timeout() -> void:
	pass # Replace with function body.

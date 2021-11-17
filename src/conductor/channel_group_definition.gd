class_name ChannelGroupDefinition
extends Object

var channels: Array
var name: String
var timings: Array = []
var total_length: float


func _init(name: String, channels: Array, timings: Array, start_position: float) -> void:
	self.name = name
	self.channels = channels
	var cumulative_duration: float = 0.0
	for t in timings:
		self.timings.append(TimingElement.new(t, cumulative_duration))
		cumulative_duration += t.duration
		t.free()
	total_length = cumulative_duration


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		channels.clear()
		# Timings not freed because they are kept by the channel group
		timings = []

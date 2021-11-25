class_name ChannelGroupDefinition
extends Object

# The audio tracks to play together as part of this channel group.
var channels: Array setget , _get_channels

# The name of the song.
var name: String setget , _get_name

# Breaks the song down into sections that can each have their own tempo and
# time signature.
var timings: Array = [] setget , _get_timings

# The total length of the song, in seconds.
var total_length: float setget , _get_total_length


# To create a new channel group definition, provide the name of the song, an
# array of AudioStream instances for the tracks in the song, and an array of
# timings identifying each section of the song.
func _init(_name: String, _channels: Array, _timings: Array) -> void:
	name = _name
	channels = _channels
	var cumulative_duration: float = 0.0
	for t in _timings:
		timings.append(TimingElement.new(t, cumulative_duration))
		cumulative_duration += t.duration
		t.free()
	total_length = cumulative_duration


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		channels.clear()
		# Timings not freed because they are kept by the channel group
		timings = []


func _get_channels() -> Array:
	return channels


func _get_name() -> String:
	return name


func _get_timings() -> Array:
	return timings


func _get_total_length() -> float:
	return total_length

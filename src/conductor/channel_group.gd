class_name ChannelGroup
extends Object
# Manages a set of correlated music channels.

const NO_BEAT = -1

# The name of the currently loaded audio group.
var name: String setget , _get_name

# The ID of the currently playing section in the audio group.
var section_id: int = 0 setget , _get_section_id

var _active_channels: int = 0
var _channels: Array
var _current_timing: TimingElement
var _last_checked_position: float = 0.0
var _next_beat: int = 0
var _next_beat_time: float = 0.0
var _timings: Array = []
var _total_length: float = 0.0
var _waiting_on_loop: bool = false


# To create a new channel group, pass an array of channel controllers.
func _init(channels: Array) -> void:
	assert(channels.size() > 0, "Can't create a channel group with 0 channels.")
	_channels = channels


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for t in _timings:
			t.free()
		_timings.clear()
		_current_timing = null
		for c in _channels:
			c.free()
		_channels.clear()


# Swaps the audio channels for the content in the provided definition.
# The new audio starts out in a muted state and will have to be explicitly set
# to the desired volume profile.
func change(definition: ChannelGroupDefinition) -> void:
	assert(_channels.size() >= definition.channels.size(),
			"Channel definition has too many tracks!")
	name = definition.name
	for c in _channels:
		var controller: = c as ChannelController
		controller.player.playing = false
	_active_channels = definition.channels.size()
	for i in range(_active_channels):
		var controller: = _channels[i] as ChannelController
		controller.player.stream = definition.channels[i]
		controller.fade(0, 0)
	for t in _timings:
		t.free()
	_timings.clear()
	_timings = definition.timings
	_total_length = definition.total_length
	seek(0.0)
	definition.free()


# Gets the number of beats in the current section of the song.
# If there is no valid song section active, returns 1 as a default.
func current_measure() -> int:
	if _current_timing == null:
		return 1
	return _current_timing.measure


# Returns the current audio playback position, in seconds.
func current_position() -> float:
	if _active_channels <= 0:
		return 0.0
	var result = _channels.front().player.get_playback_position()
	if result >= _total_length:
		seek(0.0)
	return result


# Transforms the volume profile of each track in the channel group to the
# desired value over the same period of time.  The volume profile should be a
# set of floating-point values between 0 (muted) and 1 (full volume).
func fade(duration: float, volume_profile: Array,
		pause_after_fade: bool = false) -> void:
	assert(volume_profile.size() <= _channels.size(),
			"Volume profile has too many tracks")
	for i in volume_profile.size():
		_channels[i].fade(volume_profile[i], duration, pause_after_fade)


# Checks the current track position and returns a music beat if one has occurred
# since the last check.  If no beat has occurred, returns NO_BEAT.  If a beat
# has occurred, it returns 0 for the first beat in the measure, 1 for the
# second beat, and so on.
# Call this on every frame to get a usable signal for music beats synchronized
# with the currently playing music track.
# This function will not behave reliably if the BPM is higher than the framerate
# (3600 BPM ~= 60 frames/sec) or if the track length is shorter than one frame.
func get_beat() -> int:
	if _current_timing == null:
		return NO_BEAT
	
	var position = current_position()
	# Detect and handle looping back to the beginning of the track
	if position < _last_checked_position:
		_waiting_on_loop = false
	_last_checked_position = position
	
	# Return no beat if a beat has not elapsed since the last call to get_beat
	if _waiting_on_loop or _next_beat_time > position:
		return NO_BEAT
	
	# Next beat has elapsed, cache that value and calculate the following beat
	var result = _next_beat
	_next_beat_time += _current_timing.beat_length
	_next_beat = (_next_beat + 1) % _current_timing.measure
	
	# Handle transitions between track timing elements
	if _next_beat_time > _current_timing.end:
		section_id = (section_id + 1) % _timings.size()
		if section_id == 0:
			# Detect when the next beat is at the beginning of the track
			_waiting_on_loop = true
		_current_timing = _timings[section_id]
		_next_beat_time = _current_timing.start + _current_timing.offset
		_next_beat = _current_timing.beat_offset
	return result


# Pauses audio playback.
func pause() -> void:
	print("group pause")
	for i in range(_active_channels):
		var controller = _channels[i]
		controller.pause()


# Starts audio playback.
func play() -> void:
	print("group play")
	for i in range(_active_channels):
		var controller = _channels[i]
		controller.play()


# Updates the position of the audio to the provided position in seconds.
func seek(position: float) -> void:
	for i in range(_active_channels):
		var controller = _channels[i]
		controller.player.seek(position)
	section_id = 0
	_current_timing = _timings[section_id]
	while _current_timing.end <= position:
		section_id += 1
		assert(section_id < _timings.size(),
				"Cannot seek beyond end of audio track.")
		_current_timing = _timings[section_id]
	var first_beat_time: float = _current_timing.start + _current_timing.offset
	var first_beat: int = _current_timing.beat_offset
	var beats_to_skip: int = int(ceil((position - first_beat_time)
			/ _current_timing.beat_length))
	_next_beat_time = first_beat_time + beats_to_skip \
			* _current_timing.beat_length
	_next_beat = (first_beat + beats_to_skip) % _current_timing.measure
	_last_checked_position = position
	_waiting_on_loop = false


# Updates the channel group's elapsed time for the purpose of timed audio
# effects like crossfade.
func update(delta: float) -> void:
	for c in _channels:
		c.update(delta)


func _get_name() -> String:
	return name


func _get_section_id() -> int:
	return section_id

extends Node
# The Conductor manages loading of correlated audio tracks to audio stream
# player nodes, pausing, playing, crossfading during track switches, and
# emitting signals on each beat of the music.
# Rhythm-sensitive scenes can subscribe to beat_played to synchronize game logic
# with the music track.
# The minimal use case for the conductor is load_group() to specify a new audio
# track, then swap() to put that track into the active slot, then play() to
# put the audio in a playing state.

# This signal is emitted on each beat of the currently active music track.
signal beat_played(beat_id)

const CHANNEL_COUNT = 8
const CHANNELS_PER_GROUP = 4

# The name of the currently playing audio track.
var playing_name: String setget ,  _get_playing_name

# The numeric section ID of the currently playing audio track.
var playing_section: int setget , _get_playing_section

# True if the conductor is playing, and false if not.
var playing: bool setget , _get_playing

var _fade_out_profile: Array = [0.0, 0.0, 0.0, 0.0]

onready var _front_group: = ChannelGroup.new([
	ChannelController.new($Channel0),
	ChannelController.new($Channel1),
	ChannelController.new($Channel2),
	ChannelController.new($Channel3),
])

onready var _back_group: = ChannelGroup.new([
	ChannelController.new($Channel4),
	ChannelController.new($Channel5),
	ChannelController.new($Channel6),
	ChannelController.new($Channel7),
])


func _process(delta: float) -> void:
	_front_group.update(delta)
	_back_group.update(delta)
	var beat = _front_group.get_beat()
	if beat != ChannelGroup.NO_BEAT:
		emit_signal("beat_played", beat)


func _exit_tree() -> void:
	_front_group.free()
	_back_group.free()


# Gets the number of beats in each measure of the current section of the active
# song.
func current_measure() -> int:
	return _front_group.current_measure()


# Changes the volume of each component of the active audio track over the
# specified duration (specify 0 for an instant change).
# If fading out to zero volume, consider using pause_after_fade to stop the
# music track from playing.
func fade(duration: float, volume_profile: Array,
		pause_after_fade: bool = false) -> void:
	print("fade over %s seconds with profile %s, pause %s" % [duration, volume_profile, pause_after_fade])
	_front_group.fade(duration, volume_profile, pause_after_fade)


# Loads a new audio track into a staging area in a paused, zero volume state.
func load_group(definition: ChannelGroupDefinition) -> void:
	_back_group.change(definition)


# Pauses the currently playing audio track.
func pause() -> void:
	_front_group.pause()
	playing = false


# Resumes the currently playing audio track.
func play() -> void:
	_front_group.play()
	playing = true


# Updates the position of the current audio track to the specified position.
# The position is measured in seconds.
func seek(position: float) -> void:
	_front_group.seek(position)


# Swaps the most recently staged audio track with the active track.
# The track being swapped to staging is faded to zero volume and then paused
# over the specified duration.
# The track being swapped into the active slot is faded into the specified
# volume profile over the specified duration, see the fade function.
# The newly activated audio track will start in a paused or playing state
# depending on whether the conductor is paused or playing.
func swap(fade_duration: float, volume_profile: Array) -> void:
	fade(fade_duration, _fade_out_profile, true)
	var swapped = _front_group
	_front_group = _back_group
	_back_group = swapped
	if playing:
		_front_group.play()
	else:
		_front_group.pause()
	fade(fade_duration, volume_profile)


func _get_playing_name() -> String:
	return _front_group.name


func _get_playing_section() -> int:
	return _front_group.section_id


func _get_playing() -> bool:
	return playing

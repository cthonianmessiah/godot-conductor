class_name ChannelController
extends Object
# Wraps an AudioStreamPlayer with additional features like timed volume fading.

var player: AudioStreamPlayer

var _fade_source: float = 0.0
var _fade_remaining_duration: float = 0.0
var _fade_target: float = 0.0
var _fade_total_duration: float = 0.0
var _pause_after_fade: bool = false
var _paused: bool = true
var _unpaused_volume: float = 1.0


func _init(player: AudioStreamPlayer) -> void:
	self.player = player


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		player = null


# Adjusts the volume of this controller's audio stream over a period of time.
# Overrides any previously defined fade already executing on the channel.
# Setting a negative duration will set the target volume immediately.
# The volume is a value between 0 (muted) and 1 (+0dB).
func fade(target_volume: float, fade_duration: float,
		pause_after_fade: bool = false) -> void:
	if _paused:
		_unpaused_volume = target_volume
		return
	_fade(target_volume, fade_duration, pause_after_fade)


func play() -> void:
	if not _paused and player.playing:
		return
	_paused = false
	player.play(player.get_playback_position())
	_fade(_unpaused_volume, 0.1, false)


func pause() -> void:
	if _paused and not player.playing:
		return
	_unpaused_volume = db2linear(player.volume_db)
	_paused = true
	_fade(0, 0.1, true)


# Updates the controller with elapsed time to progress the current fade
# operation, if any.
func update(delta: float) -> void:
	if _fade_remaining_duration <= 0 || delta <= 0:
		return
	_fade_remaining_duration -= delta
	if _fade_target <= 0.0 and _fade_remaining_duration <= 0:
		player.volume_db = -100.0 # Reasonably close to zero volume
		if _pause_after_fade:
			player.stop()
		return
	player.volume_db = linear2db(lerp(_fade_target, _fade_source,
			_fade_remaining_duration / _fade_total_duration))


func _fade(target_volume: float, fade_duration: float,
		pause_after_fade: bool = false) -> void:
	_fade_source = db2linear(player.volume_db)
	_fade_target = target_volume
	_fade_total_duration = fade_duration
	_fade_remaining_duration = fade_duration
	_pause_after_fade = pause_after_fade
	if _fade_remaining_duration <= 0:
		if target_volume <= 0:
			player.volume_db = -100.0
		else:
			player.volume_db = linear2db(target_volume)
		if pause_after_fade:
			player.stop()

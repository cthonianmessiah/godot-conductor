# godot-conductor
 Music conductor for track mixing and syncing game events to music beats.

Playing music in Godot may be easy, but have you ever wanted to integrate the music right into your game mechanics?  With Godot Conductor, now you can!

## Code Sample
Here's a quick sample of how to use the Conductor.

```
extends Node2D
# Demo of how to use the Conductor.

enum RhythmState {
	RED,
	BLUE,
	GREEN,
}

var Track0: AudioStream = preload("res://assets/demo_loop_t0.ogg")
var Track1: AudioStream = preload("res://assets/demo_loop_t1.ogg")
var Track2: AudioStream = preload("res://assets/demo_loop_t2.ogg")
var Track3: AudioStream = preload("res://assets/demo_loop_t3.ogg")

var _rhythm: Rhythm

onready var Anim1: AnimationPlayer = $AnimationPlayer
onready var Anim2: AnimationPlayer = $AnimationPlayer2

onready var Slider1: HSlider = $VBoxContainer/HSlider
onready var Slider2: HSlider = $VBoxContainer/HSlider2
onready var Slider3: HSlider = $VBoxContainer/HSlider3
onready var Slider4: HSlider = $VBoxContainer/HSlider4

onready var Sprite2: Sprite = $Sprite2


func _ready() -> void:
	# Load a group of audio tracks into a staging area.
	Conductor.load_group(
			# Defines a group of related audio tracks and their rhythm
			# metadata.
			ChannelGroupDefinition.new(
				# The name or ID of the song, this is in case your game objects
				# need to check which song is playing.
				"demo loop",
				# Audio tracks, by default there are 4 audio channels per group
				# allowed, but you can extend or reduce this by modifying the
				# conductor.
				[Track0, Track1, Track2, Track3],
				# Each section with different tempo or time signature gets a
				# timing definition that is used to identify beats based on time
				# coordinates from the playing audio track(s).
				[TimingDefinition.new(
					# The length of the song in seconds.  It's important that
					# you know the length and BPM of each section of the music
					# in detail if you want your game events to sync correctly.
					8.0,
					# Beats per minute (BPM) of this section of the track.
					120.0,
					# Offset between the beginning of the section and the first
					# beat, in seconds.  Helpful if your song doesn't start
					# exactly on a beat.
					0.0,
					# The number of beats per measure.  Beats will count from
					# zero, so a measure of 4 beats has beat IDs 0, 1, 2, and 3.
					4,
					# The ID of the first beat, in case the song doesn't start
					# on the first beat of a measure.
					0)]))

	# Swaps the most recently staged song with the currently playing song (if
	# any) over a configurable period of time.  This will crossfade the active
	# track to silence and fade in the new track over the same time period.
	Conductor.swap(
			# The duration, in seconds, to execute the crossfade.
			0.1,
			# The volume of each audio track in the song, between 0 (silent) and
			# 1 (+0 dB).  Silent audio tracks will continue to play to keep them
			# synchronized with audible tracks.
			[0.0, 0.0, 1.0, 1.0])

	# Starts playback on the active track.
	Conductor.play()
	
	# To connect the conductor to your game events, just use the beat_played
	# signal.
	assert(Conductor.connect("beat_played", self, "_on_beat") == 0,
			"Could not connect to beat_played signal!")
	
	# You can generate more complex signals using the Rhythm abstraction.
	_rhythm = Rhythm.new([ # Each Rhythm takes an array of RhythmElements
			# RED state, changes on beat 0, no minimum duration
			RhythmElement.new(RhythmState.RED, 0, 0),
			# GREEN state, changes on beat 1, no minimum duration
			RhythmElement.new(RhythmState.GREEN, 1, 0),
			# BLUE state, changes on beat 2, no minimum duration
			RhythmElement.new(RhythmState.BLUE, 2, 0),
		],
		# Start the rhythm on the first section (position 0 in the array)
		0,
		# Apply an offset of 0 to the conductor beat, you can use an offset to
		# configure multiple instances of a rhythm-sensitive scene to trigger
		# on different beats of the measure instead of always being in sync.
		0)
	
	# The rhythm will pass the above enum values to the signal handler, which
	# we use in this demo to control the color of the rhythm beat object.
	assert(_rhythm.connect("rhythm_advanced", self, "_on_rhythm_advanced") == 0,
			"Could not connect to rhythm_advanced signal!")


func _exit_tree() -> void:
	_rhythm.free()


# Signal handler for music beats.  The int passed to the handler identifies
# which beat in the measure just played.
# Time resolution for this handler is the resolution of the _process callback.
func _on_beat(_beat: int) -> void:
	Anim1.stop()
	Anim1.play("beat")


# Here's an example of using a button to pause and play the background music.
func _on_PlayPause_pressed() -> void:
	# The playing property is true if the conductor is playing, otherwise it is
	# false.
	if Conductor.playing:
		# Pauses playback at its current position.
		# Uses a short audio fade to reduce audio artifacts.
		Conductor.pause()
	else:
		# Resumes playback at the current position.
		# Uses a short audio fade to reduce audio artifacts.
		Conductor.play()


# Signal handler for rhythm beats.  Each ID passed corresponds to the ID of an
# element used to create the rhythm.  This can be used with enum values to
# create a cycle of state machine changes that is synced to the music.
func _on_rhythm_advanced(id: int) -> void:
	Anim2.stop()
	match id:
		RhythmState.RED:
			Anim2.play("beat_red")
		RhythmState.GREEN:
			Anim2.play("beat_green")
		RhythmState.BLUE:
			Anim2.play("beat_blue")


# Here's an example of using the fade() function to change the audio balance
# between different tracks in the same song.
func _on_volume_changed(_value) -> void:
	# The fade function changes the volume of each track in the active song over
	# a time period.  Executing a second fade will restart the interpolation
	# from whatever state the tracks were in when the second fade starts.
	Conductor.fade(
			# This is the total time in seconds that the fade will interpolate
			# over.
			0.2,
			# This is the 0..1 volume level for each audio track.
			# When you specify volume, you only have to set it on the tracks
			# that are in use, so if your audio has only one track, you only
			# need to put a single number into this array.
			[Slider1.value, Slider2.value, Slider3.value, Slider4.value])
```

Please send bug reports, questions or comments to cthonianmessiah@gmail.com or
get in touch with me on the Godot discord (cthonianmessiah).
class_name TimingDefinition
extends Object
# Defines the time signature and beat timing of a section of a song.

# The measure position of the first beat.  If the first beat in the measure, 0.
# 1 is the second beat in the measure, and so on.
var beat_offset: int setget , _get_beat_offset

# The number of beats per minute.
var bpm: float setget , _get_bpm

# The total length of the section, in seconds.
var duration: float setget , _get_duration

# The number of beats in a measure in this section.
var measure: int setget , _get_measure

# The duration between the start of the section and the first beat in the
# section.
var offset: float setget , _get_offset


# To create a timing definition, provide a duration, beats per minute, the
# offset to the first beat, the number of beats in each measure, and the first
# beat that occurs at the beginning of that section of the song.
func _init(_duration: float, _bpm: float, _offset: float, _measure: int,
		_beat_offset: int) -> void:
	assert(_offset < _duration, "Beat offset cannot exceeed section duration.")
	duration = _duration
	bpm = _bpm
	offset = _offset
	measure = _measure
	beat_offset = _beat_offset


func _get_beat_offset() -> int:
	return beat_offset


func _get_bpm() -> float:
	return bpm


func _get_duration() -> float:
	return duration


func _get_measure() -> int:
	return measure


func _get_offset() -> float:
	return offset

class_name TimingElement
extends Object
# A parsed timing element describing the time signature, beat offset, and
# boundaries of a section of a song.

# The amount of time, in seconds, for one beat to elapse, based on bpm.
var beat_length: float setget , _get_beat_length

# The measure position of the first beat.  If the first beat in the measure, 0.
# 1 is the second beat in the measure, and so on.
var beat_offset: int setget , _get_beat_offset

# The number of beats per minute.
var bpm: float setget , _get_bpm

# The total length of the section, in seconds.
var duration: float setget , _get_duration

# The point in the song where this section ends, in seconds.
var end: float setget , _get_end

# The number of beats in a measure in this section.
var measure: int setget , _get_measure

# The duration between the start of the section and the first beat in the
# section.
var offset: float setget , _get_offset

# The point in the song where this section begins, in seconds.
var start: float setget , _get_start


# To create a new timing element, pass a timing definition and the point in the
# song where the section starts.
func _init(definition: TimingDefinition, _start: float) -> void:
	duration = definition.duration
	bpm = definition.bpm
	offset = definition.offset
	measure = definition.measure
	beat_offset = definition.beat_offset
	start = _start
	end = start + duration
	beat_length = 60.0 / bpm


func _get_beat_length() -> float:
	return beat_length


func _get_beat_offset() -> int:
	return beat_offset


func _get_bpm() -> float:
	return bpm


func _get_duration() -> float:
	return duration


func _get_end() -> float:
	return end


func _get_measure() -> int:
	return measure


func _get_offset() -> float:
	return offset


func _get_start() -> float:
	return start

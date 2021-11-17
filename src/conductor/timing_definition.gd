class_name TimingDefinition
extends Object

# The measure position of the first beat.  If the first beat in the measure, 0.
# 1 is the second beat in the measure, and so on.
var beat_offset: int

# The number of beats per minute.
var bpm: float

# The total length of the section, in seconds.
var duration: float

# The number of beats in a measure in this section.
var measure: int

# The duration between the start of the section and the first beat in the
# section.
var offset: float


func _init(duration: float, bpm: float, offset: float, measure: int,
		beat_offset: int) -> void:
	assert(offset < duration, "Beat offset cannot exceeed section duration.")
	self.duration = duration
	self.bpm = bpm
	self.offset = offset
	self.measure = measure
	self.beat_offset = beat_offset

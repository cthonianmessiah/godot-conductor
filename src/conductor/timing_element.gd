class_name TimingElement
extends Object

var beat_length: float
var beat_offset: int
var bpm: float
var duration: float
var end: float
var measure: int
var offset: float
var start: float


func _init(definition: TimingDefinition, start: float) -> void:
	duration = definition.duration
	bpm = definition.bpm
	offset = definition.offset
	measure = definition.measure
	beat_offset = definition.beat_offset
	self.start = start
	end = start + duration
	beat_length = 60.0 / bpm

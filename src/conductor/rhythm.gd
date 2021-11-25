class_name Rhythm
extends Object
# Transforms beats from the conductor into a rhythm-based pattern across
# multiple beats for each section.
# 

# This signal is emitted whenever the rhythm changes between new sections.  The
# value passed to the signal handler is the numeric ID of the new section that
# is starting.  The first time this signal will be sent is when the rhythm exits
# its starting section.
signal rhythm_advanced(rhythm_element_id)

# The ID of the active rhythm element.  This isn't a position in the rhythm
# array, but rather the ID assigned to that rhythm section and emitted by the
# rhythm_advanced signal when that section was activated.
var current_element_id: int setget , _get_current_element_id

var _beat_offset: int
var _current_element: RhythmElement
var _current_element_position: int
var _elements: Array
var _remaining_beats: int


# To create a new rhythm, pass an array of rhythm elements defining the rhythm,
# the index of the element to start on, and the offset to apply when consuming
# beats from the conductor.  The offset is applied to the conductor beat,
# allowing similar rhythms to trigger at different times in the measure.
func _init(elements: Array, start_element: int, beat_offset: int) -> void:
	assert(start_element < elements.size(),
			"Rhythm start element was outside the bounds of the rhythm "
			+ "element array.")
	_elements = elements
	_current_element_position = start_element
	_current_element = _elements[start_element]
	current_element_id = _current_element.id
	_remaining_beats = _current_element.minimum_beats
	_beat_offset = beat_offset
	assert(Conductor.connect("beat_played", self, "_on_beat") == 0,
			"Rhythm could not connect to the conductor beat_played signal.")


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for e in _elements:
			e.free()
		_elements.clear()


func _get_current_element_id() -> int:
	return current_element_id


func _on_beat(beat: int) -> void:
	_remaining_beats -= 1
	if _remaining_beats > 0:
		return
	beat = (beat + _beat_offset) % Conductor.current_measure()
	if beat != _current_element.change_beat:
		return
	_current_element_position = (_current_element_position + 1) \
			% _elements.size()
	_current_element = _elements[_current_element_position]
	current_element_id = _current_element.id
	emit_signal("rhythm_advanced", current_element_id)

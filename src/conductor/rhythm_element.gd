class_name RhythmElement
extends Object
# One component of a rhythm.

# The beat that changes this rhythm element to the next element.
var change_beat: int setget , _get_change_beat

# The ID of this rhythm element.  This ID value is emitted by the rhythm when
# changing from one element to another.
var id: int setget , _get_id

# The minimum duration of this rhythm element.  If the change beat happens
# before this number of beats have elapsed, the rhythm will stay on this element
# until a later measure.
var minimum_beats: int setget , _get_minimum_beats


# To create a new rhythm element, give it an ID value, the beat when it changes
# to the next rhythm element, and the minimum number of beats.
func _init(_id: int, _change_beat: int, _minimum_beats: int) -> void:
	id = _id
	change_beat = _change_beat
	minimum_beats = _minimum_beats


func _get_change_beat() -> int:
	return change_beat


func _get_id() -> int:
	return id


func _get_minimum_beats() -> int:
	return minimum_beats

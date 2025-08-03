extends Action
class_name SwapAction

var character_data : CharacterObjectData
var command_type : int
var index : int

var duplicate_command_array = []

func _init(data: CharacterObjectData, type: int, id: int):
	self.character_data = data
	self.command_type = type
	self.index = id
	duplicate_command_array = character_data.command_array.duplicate()

func execute() -> bool:
	if index >= character_data.command_array.size():
		return false
	character_data.command_array[index] = command_type
	TurnManager.swaps_performed += 1
	character_data.command_array_changed.emit()
	return true

func debug_action():
	return ["swapped", character_data.command_type.find_key(command_type), index]

func undo():
	character_data.command_array = duplicate_command_array
	character_data.command_array_changed.emit()
	TurnManager.swaps_performed -= 1
#func swap_command(type : command_type, index: int):
	#if index >= command_array.size():
		#return
	#command_array[index] = type
	#command_array_changed.emit()
	#print("command swapped for ", ref_to_node, " at index ", index)

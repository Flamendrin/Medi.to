extends Node
class_name CommandHistory

var history: Array = []
var selection: int = -1

func push(msg, limit = 100):
	selection = -1
	history.push_front(msg)
	while history.size() > limit:
		history.pop_back()

func next():
	selection += 1
	selection = min(selection, history.size() - 1)

	if selection == -1:
		return ""
	return history[selection]

func prev():
	selection -= 1
	selection = max(selection, -1)

	if selection == -1:
		return ""
	return history[selection]


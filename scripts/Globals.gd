extends Node

class_name Globals

static var has_ring: bool = false

static func collected_ring():
	has_ring = true

static func has_collected_ring() -> bool:
	return has_ring
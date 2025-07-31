extends Node
class_name MoveActionTypes

enum MovementType { WALK, DASH, TELEPORT }

# Range calculators return Array of Vector2i positions reachable from `start`
static func get_reachable_tiles(start: Vector2i, movement_type: int, movement_budget: int) -> Array:
	match movement_type:
		MovementType.WALK:
			return _flood_fill(start, movement_budget, false)
		MovementType.DASH:
			# Dash ignores terrain cost but is limited to straight lines up to budget
			return _straight_line_dash(start, movement_budget)
		MovementType.TELEPORT:
			# Teleport can go anywhere within budget Manhattan distance, ignoring obstacles
			return _manhattan_area(start, movement_budget)
	return []

# Helper: simple BFS flood fill (4-dir), blocking if occupant present (unless overridden)
static func _flood_fill(start: Vector2i, budget: int, ignore_occupants: bool) -> Array:
	var visited := {}
	var queue := [ { "pos": start, "cost": 0 } ]
	var results := []
	while queue.size() > 0:
		var item = queue.pop_front()
		var pos: Vector2i = item["pos"]
		var cost: int = item["cost"]
		var key = str(pos.x) + "," + str(pos.y)
		if visited.has(key):
			continue
		visited[key] = true
		if cost > 0:
			results.append(pos)
		if cost >= budget:
			continue
		for delta in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var neighbor = pos + delta
			# Example obstacle logic: block if there's any occupant (unless ignore)
			var cell = GridManager.get_cell_data(neighbor, false)
			if cell and cell.occupants.size() > 0 and not ignore_occupants:
				continue
			queue.append({ "pos": neighbor, "cost": cost + 1 })
	return results

static func _straight_line_dash(start: Vector2i, budget: int) -> Array:
	var results := []
	for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		for step in range(1, budget + 1):
			results.append(start + dir * step)
	return results

static func _manhattan_area(start: Vector2i, radius: int) -> Array:
	var results := []
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if abs(dx) + abs(dy) <= radius and not (dx == 0 and dy == 0):
				results.append(start + Vector2i(dx, dy))
	return results

extends Node2D

# Function to find the nearest idle carrier
func find_nearest_carrier(beacon_position: Vector2) -> Node2D:
	var nearest_carrier = null
	var min_distance = INF
	for carrier in get_tree().get_nodes_in_group("carriers"):
		if carrier.state == "idle":
			var distance = carrier.global_position.distance_to(beacon_position)
			if distance < min_distance:
				min_distance = distance
				nearest_carrier = carrier
	return nearest_carrier


# Function to find the nearest idle crawler
func find_nearest_crawler() -> Node2D:
	var nearest_crawler = null
	var min_distance = INF
	for crawler in get_tree().get_nodes_in_group("crawlers"):
		if crawler.is_idle():  # Ensure the crawler is idle
			var distance = crawler.global_position.distance_to(global_position)  # Use your base position here
			if distance < min_distance:
				min_distance = distance
				nearest_crawler = crawler
	return nearest_crawler


# Function to activate the carrier for the beacon
func activate_carrier_for_beacon(beacon_position: Vector2) -> void:
	var carrier = find_nearest_carrier(beacon_position)
	var crawler = find_nearest_crawler()
	if carrier and crawler:
		print("Activating carrier for beacon at: ", beacon_position)
		carrier.activate(beacon_position, crawler)
	else:
		print("No available carrier or crawler!")

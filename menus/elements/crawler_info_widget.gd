extends MarginContainer

var crawler: Node = null

func set_crawler(crawler_ref):
	crawler = crawler_ref
	update_labels()


func update_labels():
	if crawler:
		$"Crawler Info/Machine #".text = String("%d" % crawler.crawler_id).pad_zeros(2)
		$"Crawler Info/Labels/Status".text = "%s" % crawler.state
		$"Crawler Info/Labels/Spice".text = "%d / %d" % [crawler.current_spice, crawler.max_storage]



func _process(delta: float) -> void:
	update_labels()

extends MarginContainer

var carrier: Node = null

func set_carrier(carrier_ref):
	carrier = carrier_ref
	update_labels()


func update_labels():
	if carrier:
		$"Carrier Info/Machine #".text = String("%d" % carrier.carrier_id).pad_zeros(2)
		$"Carrier Info/Labels/Status".text = "%s" % carrier.state
		$"Carrier Info/Labels/Fuel".text = "Fuel: xxx"



func _process(delta: float) -> void:
	update_labels()

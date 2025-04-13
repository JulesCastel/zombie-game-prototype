extends Node

func instanceNode(node, location, parent, nodeName):
	var nodeInstance = node.instantiate()
	parent.add_child(nodeInstance)
	nodeInstance.global_position = location
	nodeInstance.name = nodeName
	return nodeInstance

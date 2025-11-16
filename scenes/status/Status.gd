class_name Status extends Node

enum Type {
	BURN,
	SLOW,
	BLOCK,
	THORNS,
	STRENGTH
}

var effect: Type = Type.BURN

var stacks: int = 3

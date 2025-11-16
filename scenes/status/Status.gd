class_name Status extends Node

enum Type {
	BURN,
	SLOW,
	BLOCK,
	THORNS
}

var effect: Type = Type.BURN

var stacks: int = 3

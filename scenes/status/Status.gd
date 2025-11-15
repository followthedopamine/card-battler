class_name Status extends Node

enum Type {
	BURN,
	SLOW,
	BLOCK
}

var effect: Type = Type.BURN

var stacks: int = 3

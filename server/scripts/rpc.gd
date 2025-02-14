extends Node

@rpc
func print_once_per_client():
	print("I will be printed to the console once per each connected client.")

class_name DiscoveryBook
extends RefCounted
static func entries() -> Dictionary:
	return Content.discoveries()

static func known(run: RunState) -> Array[String]:
	var ids: Array[String]=[]
	for id in entries():
		if id in run.discoveries or id in run.vault.memories or id in run.vault.relics or (id=="source_binding" and run.source.seen) or (id=="source_restored" and run.source.resolution=="restored") or (id=="source_broken" and run.source.resolution=="broken"):
			ids.append(id)
	return ids

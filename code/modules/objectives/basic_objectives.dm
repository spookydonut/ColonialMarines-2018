// --------------------------------------------
// *** Basic retrieve item and get it to an area ***
// --------------------------------------------
/datum/cm_objective/retrieve_item
	var/obj/item/target_item
	var/area/target_area
	var/area/initial_location
	objective_flags = OBJ_CAN_BE_UNCOMPLETED | OBJ_FAILABLE
	display_category = "Item Retrieval"

/datum/cm_objective/retrieve_item/New(var/obj/item/T)
	..()
	if(T)
		target_item = T
		initial_location = get_area(target_item)

/datum/cm_objective/retrieve_item/get_clue()
	return "[target_item] in [initial_location]"

/datum/cm_objective/retrieve_item/check_completion()
	. = ..()
	if(!target_item)
		fail()
		return 0
	if(target_item.is_damaged())
		uncomplete()
		return 0
	if(istype(get_area(target_item), target_area))
		complete()
		return 1

/datum/cm_objective/retrieve_item/almayer
	target_area = /area/almayer/command/securestorage
	priority = OBJECTIVE_LOW_VALUE

// --------------------------------------------
// *** Get communications up ***
// --------------------------------------------
/datum/cm_objective/communications
	name = "Restore Colony Communications"
	objective_flags = OBJ_DO_NOT_TREE | OBJ_CAN_BE_UNCOMPLETED
	display_flags = OBJ_DISPLAY_AT_END

/datum/cm_objective/communications/get_completion_status()
	if(is_complete())
		return "<span class='objectivegreen'>Comms are up!</span>"
	return "<span class='objectivered'>Comms are down!</span>"

/datum/cm_objective/communications/check_completion()
	. = ..()
	for(var/obj/machinery/telecomms/relay/T in machines)
		if(!(T.loc.z in SURFACE_Z_LEVELS))
			continue
		if(!T.powered())
			continue
		complete()
		return 1
	uncomplete()
	return 0

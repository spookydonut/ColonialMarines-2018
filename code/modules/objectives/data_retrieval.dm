
// --------------------------------------------
// *** Slightly more complicated data retrieval ***
// --------------------------------------------
/datum/cm_objective/retrieve_data
	name = "Retrieve Important Data"
	var/data_total = 100
	var/data_retrieved = 0
	var/data_transfer_rate = 10
	var/area/initial_location
	objective_flags = OBJ_FAILABLE
	var/decryption_password
	display_category = "Data Retrieval"

/datum/cm_objective/retrieve_data/New()
	..()
	var/list/letters = list("A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","T","U","V","X","Y","Z") // please find a better way to do this
	decryption_password = "[pick(letters)][rand(100,999)][pick(letters)][rand(10,99)]"

/datum/cm_objective/retrieve_data/check_completion()
	. = ..()
	if(data_retrieved >= data_total)
		complete()
		return 1

/datum/cm_objective/retrieve_data/process()
	if(..())
		if(data_is_avaliable())
			data_retrieved += data_transfer_rate

/datum/cm_objective/retrieve_data/proc/data_is_avaliable()
	if(objective_flags & OBJ_REQUIRES_COMMS)
		if(objectives_controller && objectives_controller.comms && objectives_controller.comms.is_complete())
			return 1
		else
			return 0
	return 1

/datum/cm_objective/retrieve_data/complete()
	if(..())
		var/name = "[MAIN_AI_SYSTEM]"
		var/input = "Data Analysis Complete. The following leads have been generated:\n"
		var/clues = 0
		for(var/datum/cm_objective/O in enables_objectives)
			if(O.is_prerequisites_completed())
				O.activate()
				input += "[O.get_clue()]\n"
				clues++
		if(clues)
			command_announcement.Announce(input, name, new_sound = 'sound/AI/commandreport.ogg')
		return 1
	return 0

// --------------------------------------------
// *** Upload data from a terminal ***
// --------------------------------------------
/datum/cm_objective/retrieve_data/terminal
	var/obj/machinery/computer/objective/data_source
	priority = OBJECTIVE_HIGH_VALUE
	objective_flags = OBJ_FAILABLE | OBJ_REQUIRES_POWER | OBJ_REQUIRES_COMMS
	prerequisites_required = PREREQUISITES_MAJORITY

/datum/cm_objective/retrieve_data/terminal/New(var/obj/machinery/computer/objective/D)
	data_source = D
	initial_location = get_area(data_source)
	..()

/datum/cm_objective/retrieve_data/terminal/complete()
	if(..())
		data_source.visible_message("<span class='notice'>[data_source] pings softly as it finishes the upload.</span>")
		playsound(data_source, 'sound/machines/ping.ogg', 25, 1)

/datum/cm_objective/retrieve_data/terminal/get_clue()
	return "Upload data from [data_source] in [get_area(data_source)], the password is [decryption_password]"

/datum/cm_objective/retrieve_data/terminal/data_is_avaliable()
	. = ..()
	if(!data_source.powered())
		return 0
	if(!data_source.uploading)
		return 0

// --------------------------------------------
// *** Retrieve a disk and upload it ***
// --------------------------------------------
/datum/cm_objective/retrieve_data/disk
	var/obj/item/disk/objective/disk
	priority = OBJECTIVE_MEDIUM_VALUE
	prerequisites_required = PREREQUISITES_ONE

/datum/cm_objective/retrieve_data/disk/New(var/obj/item/disk/objective/O)
	disk = O
	data_total = disk.data_amount
	data_transfer_rate = disk.read_speed
	initial_location = get_area(disk)
	..()

/datum/cm_objective/retrieve_data/disk/complete()
	if(..())
		if(istype(disk.loc,/obj/machinery/computer/disk_reader))
			var/obj/machinery/computer/disk_reader/reader = disk.loc
			reader.visible_message("\The [reader] pings softly as the upload finishes and ejects the disk.")
			playsound(reader, 'sound/machines/ping.ogg', 25, 1)
			disk.forceMove(reader.loc)
			reader.disk = null
		return 1
	return 0

/datum/cm_objective/retrieve_data/disk/get_clue()
	return "retrieving disk [disk] in [initial_location], decryption password is [decryption_password]"

/datum/cm_objective/retrieve_data/disk/data_is_avaliable()
	. = ..()
	if(!istype(disk.loc,/obj/machinery/computer/disk_reader))
		return 0
	var/obj/machinery/computer/disk_reader/reader = disk.loc
	if(!reader.powered())
		return 0
	if(reader.z != MAIN_SHIP_Z_LEVEL)
		return 0

// --------------------------------------------
// *** Mapping objects *** 
// *** Retrieve a disk and upload it ***
// --------------------------------------------
/obj/item/disk/objective
	name = "computer disk"
	desc = "A boring looking computer disk.  The name label is just a gibberish collection of letters and numbers."
	var/data_amount = 500
	var/read_speed = 50
	unacidable = 1
	var/datum/cm_objective/retrieve_data/disk/objective

/obj/item/disk/objective/New()
	..()
	var/letters = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")
	name = "computer disk [pick(letters)]-[rand(100,999)]"
	objective = new /datum/cm_objective/retrieve_data/disk(src)

/obj/item/disk/objective/Dispose()
	if(objective)
		objective.fail()
	..()

// --------------------------------------------
// *** Upload data from a terminal ***
// --------------------------------------------
/obj/machinery/computer/objective
	name = "data terminal"
	desc = "A computer data terminal with an incomprehensible label."
	var/uploading = 0
	icon_state = "medlaptop"
	unacidable = 1
	var/datum/cm_objective/retrieve_data/terminal/objective

/obj/machinery/computer/objective/New()
	..()
	var/letters = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")
	name = "data terminal [pick(letters)]-[rand(100,999)]"
	objective = new /datum/cm_objective/retrieve_data/terminal(src)

/obj/machinery/computer/objective/Dispose()
	if(objective)
		objective.fail()
	..()

/obj/machinery/computer/objective/attack_hand(mob/living/user)
	if(!powered())
		to_chat(user, "<span class='warning'>This terminal has no power!</span>")
		return 0
	if(objective.objective_flags & OBJ_REQUIRES_COMMS)
		if(!objectives_controller || !objectives_controller.comms || !objectives_controller.comms.is_complete())
			to_chat(user, "<span class='warning'>The terminal flashes a network connection error.</span>")
			return 0
	if(objective.is_complete())
		to_chat(user, "<span class='warning'>There's a message on the screen that the data upload finished successfully.</span>")
		return 1
	if(uploading)
		to_chat(user, "<span class='warning'>Looks like the terminal is already uploading, better make sure nothing interupts it!</span>")
		return 1
	if(input(user,"Enter the password","Password","") != objective.decryption_password)
		to_chat(user, "<span class='warning'>The terminal rejects the password.</span>")
		return 0
	if(!objective.is_active())
		objective.activate(1) // force it active now, we have the password
	if(!powered())
		to_chat(user, "<span class='warning'>This terminal has no power!</span>")
		return 0
	if(objective.objective_flags & OBJ_REQUIRES_COMMS)
		if(!objectives_controller || !objectives_controller.comms || !objectives_controller.comms.is_complete())
			to_chat(user, "<span class='warning'>The terminal flashes a network connection error.</span>")
			return 0
	if(uploading)
		to_chat(user, "<span class='warning'>Looks like the terminal is already uploading, better make sure nothing interupts it!</span>")
		return 1
	uploading = 1
	to_chat(user, "<span class='notice'>You start uploading the data.</span>")

// --------------------------------------------
// *** Upload data from an inserted disk ***
// --------------------------------------------
/obj/machinery/computer/disk_reader
	name = "universal disk reader"
	desc = "A console able to read any format of disk known to man."
	var/obj/item/disk/objective/disk
	icon_state = "medlaptop"
	unacidable = 1

/obj/machinery/computer/disk_reader/attack_hand(mob/living/user)
	if(isXeno(user))
		return
	if(disk)
		to_chat(user, "<span class='notice'>[disk] is currently loaded into the machine.</span>")
		if(disk.objective)
			if(disk.objective.is_active() && !disk.objective.is_complete() && disk.objective.data_is_avaliable())
				to_chat(user, "<span class='notice'>Data is currently being uploaded to ARES.</span>")
				return
		to_chat(user, "<span class='notice'>No data is being uploaded.</span>")
		
/obj/machinery/computer/disk_reader/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/disk/objective))
		if(istype(disk))
			to_chat(user, "<span class='warning'>There is a disk in the drive being uploaded already!</span>")
			return 0
		var/obj/item/disk/objective/newdisk = W
		if(newdisk.objective.is_complete())
			to_chat(user, "<span class='warning'>The reader displays a message stating this disk has already been read and refuses to accept it.</span>")
			return 0
		if(input(user,"Enter the encryption key","Encryption key","") != newdisk.objective.decryption_password)
			to_chat(user, "<span class='warning'>The reader asks for the encryption key for this disk, not having the correct key you eject the disk.</span>")
			return 0
		if(!newdisk.objective.is_active())
			newdisk.objective.activate(1) // force it active now, we have the password
		if(istype(disk))
			to_chat(user, "<span class='warning'>There is a disk in the drive being uploaded already!</span>")
			return 0

		if(!(newdisk in user.contents))
			return 0

		user.drop_inv_item_to_loc(W, src)
		disk = W
		to_chat(user, "<span class='notice'>You insert \the [W] and enter the decryption key.</span>")

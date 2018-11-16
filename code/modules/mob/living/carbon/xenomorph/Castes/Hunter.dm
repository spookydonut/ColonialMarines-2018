/datum/xeno_caste/hunter
	caste_name = "Hunter"
	display_name = "Hunter"
	upgrade_name = "Young"
	caste_desc = "A fast, powerful front line combatant."

	caste_type_path = /mob/living/carbon/Xenomorph/Hunter

	tier = 2
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30
	attack_delay = -1 

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.5

	// *** Plasma *** //
	plasma_max = 100
	plasma_gain = 10

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	evolves_to = list("Ravager")
	deevolves_to = "Runner" 

	// *** Defense *** //
	armor_deflection = 10 

	// *** Ranged Attack *** //
	charge_type = 2 //Pounce - Hunter
	pounce_delay = 150

/datum/xeno_caste/hunter/mature
	upgrade_name = "Mature"
	caste_desc = "A fast, powerful front line combatant. It looks a little more dangerous."
	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 40
	attack_delay = -1.25

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.6

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 15

	// *** Health *** //
	max_health = 175

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	pounce_delay = 125

/datum/xeno_caste/hunter/elder
	upgrade_name = "Elder"
	caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45
	attack_delay = -1.4

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -1.7

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 18

	// *** Health *** //
	max_health = 190

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 18

	// *** Ranged Attack *** //
	pounce_delay = 110

/datum/xeno_caste/hunter/ancient
	upgrade_name = "Ancient"
	caste_desc = "A fast, powerful front line combatant. It looks pretty strong."
	upgrade = 3
	ancient_message = "You are the epitome of the hunter. Few can stand against you in open combat."

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 50
	attack_delay = -1.5

	// *** Tackle *** //
	tackle_damage = 50

	// *** Speed *** //
	speed = -1.7

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 18

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	pounce_delay = 100	

/mob/living/carbon/Xenomorph/Hunter
	caste_name = "Hunter"
	name = "Hunter"
	desc = "A beefy, fast alien with sharp claws."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Hunter Running"
	health = 150
	maxHealth = 150
	plasma_stored = 50
	tier = 2
	upgrade = 0
	var/stealth_delay = null
	var/last_stealth = null
	var/used_stealth = FALSE
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/pounce,
		/datum/action/xeno_action/activable/stealth,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

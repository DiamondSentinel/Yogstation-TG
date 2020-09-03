/datum/guardian_ability/major/gravity
	name = "Gravity"
	desc = "The guardian's punches apply heavy gravity to whatever it punches."
	cost = 3
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/graviton_wave
	var/list/gravito_targets = list()

/datum/guardian_ability/major/gravity/Apply()
	RegisterSignal(guardian, COMSIG_MOVABLE_MOVED, .proc/recheck_distances)

/datum/guardian_ability/major/gravity/Remove()
	UnregisterSignal(guardian, COMSIG_MOVABLE_MOVED)

/datum/guardian_ability/major/gravity/Attack(atom/target)
	if(isliving(target) && target != guardian)
		to_chat(guardian, "<span class='danger'><B>Your punch has applied heavy gravity to [target]!</span></B>")
		add_gravity(target, 2)
		to_chat(target, "<span class='userdanger'>Everything feels really heavy!</span>")

/datum/guardian_ability/major/gravity/Recall()
	for(var/datum/component/C in gravito_targets)
		if(get_dist(src, C.parent) > (master_stats.potential * 2))
			remove_gravity(C)

/datum/guardian_ability/major/gravity/proc/recheck_distances()
	for(var/datum/component/C in gravito_targets)
		if(get_dist(src, C.parent) > (master_stats.potential * 2))
			remove_gravity(C)

/obj/effect/proc_holder/spell/aoe_turf/guardian/graviton_wave
	name = "Graviton Wave"
	desc = "Emanates a wave of graviton particles, inflicting massive gravity on all targets."
	panel = "Holoparasite"
	charge_max = 100

/obj/effect/proc_holder/spell/aoe_turf/guardian/graviton_wave/cast(list/targets,mob/user = usr)
	for(var/mob/living/C in targets)
			if(C != guardian && C != guardian.summoner?.current)
				add_gravity(C, 4)
		guardian.visible_message("<span class='danger'>A massive graviton wave emanates from [src]!</span>", "<span class='notice'>You modify the gravity around you.</span>")
		playsound(guardian, 'sound/effects/gravhit.ogg', 100, TRUE)

/datum/guardian_ability/major/gravity/proc/add_gravity(atom/A, new_gravity = 2)
    var/datum/component/C = A.AddComponent(/datum/component/forced_gravity,new_gravity)
    RegisterSignal(A, COMSIG_MOVABLE_MOVED, .proc/__distance_check)
    gravito_targets.Add(C)
    playsound(src, 'sound/effects/gravhit.ogg', 100, 1)

/datum/guardian_ability/major/gravity/proc/remove_gravity(datum/component/C)
	UnregisterSignal(C.parent, COMSIG_MOVABLE_MOVED)
	gravito_targets.Remove(C)
	qdel(C)

/datum/guardian_ability/major/gravity/proc/__distance_check(atom/movable/AM, OldLoc, Dir, Forced)
	if(get_dist(src, AM) > (master_stats.potential * 2))
		remove_gravity(AM.GetComponent(/datum/component/forced_gravity))

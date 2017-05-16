/obj/item/wallframe
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT*2)
	flags = CONDUCT
	origin_tech = "materials=1;engineering=1"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_SMALL
	var/result_path
	var/inverse = 0
	// For inverse dir frames like light fixtures.

/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall,user)>1)
		return
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinal))
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(user, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return
	if(A.always_unpowered)
		to_chat(user, "<span class='warning'>You cannot place [src] in this area!</span>")
		return
	if(gotwallitem(T, ndir, inverse*2))
		to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
		return

	return TRUE

/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(result_path)
		playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
		user.visible_message("[user.name] attaches [src] to the wall.",
			"<span class='notice'>You attach [src] to the wall.</span>",
			"<span class='italics'>You hear clicking.</span>")
		var/ndir = get_dir(on_wall,user)
		if(inverse)
			ndir = turn(ndir, 180)

		var/obj/O = new result_path(get_turf(user), ndir, 1)
		after_attach(O)

	qdel(src)

/obj/item/wallframe/proc/after_attach(var/obj/O)
	transfer_fingerprints_to(O)

/obj/item/wallframe/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/screwdriver))
		// For camera-building borgs
		var/turf/T = get_step(get_turf(user), user.dir)
		if(iswallturf(T))
			T.attackby(src, user, params)

	var/metal_amt = round(materials[MAT_METAL]/MINERAL_MATERIAL_AMOUNT)
	var/glass_amt = round(materials[MAT_GLASS]/MINERAL_MATERIAL_AMOUNT)

	if(istype(W, /obj/item/weapon/wrench) && (metal_amt || glass_amt))
		to_chat(user, "<span class='notice'>You dismantle [src].</span>")
		if(metal_amt)
			new /obj/item/stack/sheet/metal(get_turf(src), metal_amt)
		if(glass_amt)
			new /obj/item/stack/sheet/glass(get_turf(src), glass_amt)
		qdel(src)



// APC HULL
/obj/item/wallframe/apc
	name = "\improper APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	result_path = /obj/machinery/power/apc
	inverse = 1


/obj/item/wallframe/apc/try_build(turf/on_wall, user)
	if(!..())
		return
	var/turf/T = get_turf(user)
	var/area/A = get_area(T)
	if(A.get_apc())
		to_chat(user, "<span class='warning'>This area already has an APC!</span>")
		return //only one APC per area
	if(!A.requires_power)
		to_chat(user, "<span class='warning'>You cannot place [src] in this area!</span>")
		return //can't place apcs in areas with no power requirement
	for(var/obj/machinery/power/terminal/E in T)
		if(E.master)
			to_chat(user, "<span class='warning'>There is another network terminal here!</span>")
			return
		else
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(T)
			C.amount = 10
			to_chat(user, "<span class='notice'>You cut the cables and disassemble the unused power terminal.</span>")
			qdel(E)
	return TRUE


/obj/item/weapon/electronics
	desc = "Looks like a circuit. Probably is."
	icon = 'icons/obj/module.dmi'
	icon_state = "door_electronics"
	item_state = "electronic"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=2;programming=1"
	materials = list(MAT_METAL=50, MAT_GLASS=50)
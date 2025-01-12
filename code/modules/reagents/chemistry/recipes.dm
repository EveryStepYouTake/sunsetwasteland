/datum/chemical_reaction
	var/name = null
	var/id = null
	var/list/results = new/list()
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	/// Higher is higher priority, determines which order reactions are checked.
	var/priority = CHEMICAL_REACTION_PRIORITY_DEFAULT

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/required_container = null // the exact container path required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/mob_react = TRUE //Determines if a chemical reaction can occur inside a mob

	var/required_temp = 0
	var/is_cold_recipe = 0 // Set to 1 if you want the recipe to only react when it's BELOW the required temp.
	var/special_react = FALSE //Determines if the recipe has special conditions for it to react. Mainly used for ling blood tests
	var/mix_message = "The solution begins to bubble." //The message shown to nearby people upon mixing, if applicable
	var/mix_sound = 'sound/effects/bubbles.ogg' //The sound played upon mixing, if applicable

	//FermiChem!
	var/OptimalTempMin 			= 200 		// Lower area of bell curve for determining heat based rate reactions
	var/OptimalTempMax			= 800		// Upper end for above
	var/ExplodeTemp 			= 900 		// Temperature at which reaction explodes - If any reaction is this hot, it explodes!
	var/OptimalpHMin 			= 5         // Lowest value of pH determining pH a 1 value for pH based rate reactions (Plateu phase)
	var/OptimalpHMax 			= 10        // Higest value for above
	var/ReactpHLim 				= 3         // How far out pH wil react, giving impurity place (Exponential phase)
	var/CatalystFact 			= 0 		// How much the catalyst affects the reaction (0 = no catalyst)//Not implemented yet
	var/CurveSharpT 			= 2         // How sharp the temperature exponential curve is (to the power of value)
	var/CurveSharppH 			= 2         // How sharp the pH exponential curve is (to the power of value)
	var/ThermicConstant 		= 1         // Temperature change per 1u produced
	var/HIonRelease 			= 0.1       // pH change per 1u reaction
	var/RateUpLim 				= 10        // Optimal/max rate possible if all conditions are perfect
	var/FermiChem				= FALSE 	// If the chemical uses the Fermichem reaction mechanics//If the chemical uses the Fermichem reaction mechanics
	var/FermiExplode 			= FALSE 	// If the chemical explodes in a special way
	var/clear_conversion						//bitflags for clear conversions; REACTION_CLEAR_IMPURE or REACTION_CLEAR_INVERSE
	var/PurityMin 				= 0.15 		//If purity is below 0.15, it explodes too. Set to 0 to disable this.


/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, multiplier, specialreact)
	return
	//I recommend you set the result amount to the total volume of all components.

/datum/chemical_reaction/proc/check_special_react(datum/reagents/holder)
	return

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)


		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_act()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/simple_animal/S = create_random_mob(get_turf(holder.my_atom), mob_class)
			S.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(S, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/proc/goonchem_vortex(turf/T, setting_type, range)
	for(var/atom/movable/X in orange(range, T))
		if(iseffect(X))
			continue
		if(!X.anchored)
			var/distance = get_dist(X, T)
			var/moving_power = max(range - distance, 1)
			if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
				if(setting_type)
					var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
					X.throw_at(throw_target, moving_power, 1)
				else
					X.throw_at(T, moving_power, 1)
			else
				spawn(0) //so everything moves at the same time.
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_away(X, T))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_towards(X, T))
								break

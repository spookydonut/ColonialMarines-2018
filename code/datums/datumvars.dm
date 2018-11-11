
// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

/datum/proc/vv_edit_var(var_name, var_value) //called whenever a var is edited
	if(var_name == NAMEOF(src, vars))
		return FALSE
	vars[var_name] = var_value
	datum_flags |= DF_VAR_EDITED
	return TRUE

client
	proc/debug_variables(datum/D in world)
		set category = "Debug"
		set name = "View Variables"

		if(!usr.client || !usr.client.holder || !(usr.client.holder.rights & R_MOD))
			to_chat(usr, "\red You need to be a moderator or higher to access this.")
			return

		if(!D)	return

		var/title = ""
		var/body = ""

		//Sort of a temporary solution for right now.
		if(istype(D,/datum/admins) && !(ishost(usr))) //Prevents non-hosts from changing their own permissions.
			to_chat(usr, "<span class='warning'>You need host permission to access this.</span>")
			return

		if((istype(D,/datum/ammo) || istype(D,/mob/living/carbon/Xenomorph/Predalien)) && !(usr.client.holder.rights & R_DEBUG))
			to_chat(usr, "<span class='warning'>You need debugging permission to access this.</span>")
			return

		if(istype(D, /atom))
			var/atom/A = D
			title = "[A.name] (\ref[A]) = [A.type]"

			#ifdef VARSICON
			if (A.icon)
				body += debug_variable("icon", new/icon(A.icon, A.icon_state, A.dir), 0)
			#endif

		var/icon/sprite

		if(istype(D,/atom))
			var/atom/AT = D
			if(AT.icon && AT.icon_state)
				sprite = new /icon(AT.icon, AT.icon_state)
				usr << browse_rsc(sprite, "view_vars_sprite.png")

		title = "[D] (\ref[D]) = [D.type]"

		body += {"<script type="text/javascript">

					function updateSearch(){
						var filter_text = document.getElementById('filter');
						var filter = filter_text.value.toLowerCase();

						if(event.keyCode == 13){	//Enter / return
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										alist = lis\[i\].getElementsByTagName("a")
										if(alist.length > 0){
											location.href=alist\[0\].href;
										}
									}
								}catch(err) {   }
							}
							return
						}

						if(event.keyCode == 38){	//Up arrow
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										if( (i-1) >= 0){
											var li_new = lis\[i-1\];
											li.style.backgroundColor = "white";
											li_new.style.backgroundColor = "#ffee88";
											return
										}
									}
								}catch(err) {  }
							}
							return
						}

						if(event.keyCode == 40){	//Down arrow
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");
							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.style.backgroundColor == "#ffee88" )
									{
										if( (i+1) < lis.length){
											var li_new = lis\[i+1\];
											li.style.backgroundColor = "white";
											li_new.style.backgroundColor = "#ffee88";
											return
										}
									}
								}catch(err) {  }
							}
							return
						}

						//This part here resets everything to how it was at the start so the filter is applied to the complete list. Screw efficiency, it's client-side anyway and it only looks through 200 or so variables at maximum anyway (mobs).
						if(complete_list != null && complete_list != ""){
							var vars_ol1 = document.getElementById("vars");
							vars_ol1.innerHTML = complete_list
						}

						if(filter.value == ""){
							return;
						}else{
							var vars_ol = document.getElementById('vars');
							var lis = vars_ol.getElementsByTagName("li");

							for ( var i = 0; i < lis.length; ++i )
							{
								try{
									var li = lis\[i\];
									if ( li.innerText.toLowerCase().indexOf(filter) == -1 )
									{
										vars_ol.removeChild(li);
										i--;
									}
								}catch(err) {   }
							}
						}
						var lis_new = vars_ol.getElementsByTagName("li");
						for ( var j = 0; j < lis_new.length; ++j )
						{
							var li1 = lis\[j\];
							if (j == 0){
								li1.style.backgroundColor = "#ffee88";
							}else{
								li1.style.backgroundColor = "white";
							}
						}
					}



					function selectTextField(){
						var filter_text = document.getElementById('filter');
						filter_text.focus();
						filter_text.select();

					}

					function loadPage(list) {

						if(list.options\[list.selectedIndex\].value == ""){
							return;
						}

						location.href=list.options\[list.selectedIndex\].value;

					}
				</script> "}

		body += "<body onload='selectTextField(); updateSearch()' onkeyup='updateSearch()'>"

		body += "<div align='center'><table width='100%'><tr><td width='50%'>"

		if(sprite)
			body += "<table align='center' width='100%'><tr><td><img src='view_vars_sprite.png'></td><td>"
		else
			body += "<table align='center' width='100%'><tr><td>"

		body += "<div align='center'>"

		if(istype(D,/atom))
			var/atom/A = D
			if(isliving(A))
				body += "<a href='?_src_=vars;rename=\ref[D]'><b>[D]</b></a>"
				if(A.dir)
					body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
				var/mob/living/M = A
				body += "<br><font size='1'><a href='?_src_=vars;datumedit=\ref[D];varnameedit=ckey'>[M.ckey ? M.ckey : "No ckey"]</a> / <a href='?_src_=vars;datumedit=\ref[D];varnameedit=real_name'>[M.real_name ? M.real_name : "No real name"]</a></font>"
				body += {"
				<br><font size='1'>
				BRUTE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brute'>[M.getBruteLoss()]</a>
				FIRE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=fire'>[M.getFireLoss()]</a>
				TOXIN:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=toxin'>[M.getToxLoss()]</a>
				OXY:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=oxygen'>[M.getOxyLoss()]</a>
				CLONE:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=clone'>[M.getCloneLoss()]</a>
				BRAIN:<font size='1'><a href='?_src_=vars;mobToDamage=\ref[D];adjustDamage=brain'>[M.getBrainLoss()]</a>
				</font>


				"}
			else
				body += "<a href='?_src_=vars;datumedit=\ref[D];varnameedit=name'><b>[D]</b></a>"
				if(A.dir)
					body += "<br><font size='1'><a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=left'><<</a> <a href='?_src_=vars;datumedit=\ref[D];varnameedit=dir'>[dir2text(A.dir)]</a> <a href='?_src_=vars;rotatedatum=\ref[D];rotatedir=right'>>></a></font>"
		else
			body += "<b>[D]</b>"

		body += "</div>"

		body += "</tr></td></table>"

		var/formatted_type = text("[D.type]")
		if(length(formatted_type) > 25)
			var/middle_point = length(formatted_type) / 2
			var/splitpoint = findtext(formatted_type,"/",middle_point)
			if(splitpoint)
				formatted_type = "[copytext(formatted_type,1,splitpoint)]<br>[copytext(formatted_type,splitpoint)]"
			else
				formatted_type = "Type too long" //No suitable splitpoint (/) found.

		body += "<div align='center'><b><font size='1'>[formatted_type]</font></b>"

		if(src.holder && src.holder.marked_datum && src.holder.marked_datum == D)
			body += "<br><font size='1' color='red'><b>Marked Object</b></font>"

		body += "</div>"

		body += "</div></td>"

		body += "<td width='50%'><div align='center'><a href='?_src_=vars;datumrefresh=\ref[D]'>Refresh</a>"

		//if(ismob(D))
		//	body += "<br><a href='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</a></div></td></tr></table></div><hr>"

		body += {"	<form>
					<select name="file" size="1"
					onchange="loadPage(this.form.elements\[0\])"
					target="_parent._top"
					onmouseclick="this.focus()"
					style="background-color:#ffffff">
				"}

		body += {"	<option value>Select option</option>
  					<option value> </option>
				"}


		body += "<option value='?_src_=vars;mark_object=\ref[D]'>Mark Object</option>"
		if(ismob(D))
			body += "<option value='?_src_=vars;mob_player_panel=\ref[D]'>Show player panel</option>"

		body += "<option value>---</option>"

		if(ismob(D))
			body += "<option value='?_src_=vars;give_spell=\ref[D]'>Give Spell</option>"
			body += "<option value='?_src_=vars;give_disease=\ref[D]'>Give TG-style Disease</option>"
			body += "<option value='?_src_=vars;godmode=\ref[D]'>Toggle Godmode</option>"
			body += "<option value='?_src_=vars;build_mode=\ref[D]'>Toggle Build Mode</option>"

			body += "<option value='?_src_=vars;ninja=\ref[D]'>Make Space Ninja</option>"
			body += "<option value='?_src_=vars;make_skeleton=\ref[D]'>Make 2spooky</option>"

			body += "<option value='?_src_=vars;direct_control=\ref[D]'>Assume Direct Control</option>"
			body += "<option value='?_src_=vars;drop_everything=\ref[D]'>Drop Everything</option>"

			body += "<option value='?_src_=vars;regenerateicons=\ref[D]'>Regenerate Icons</option>"
			body += "<option value='?_src_=vars;addlanguage=\ref[D]'>Add Language</option>"
			body += "<option value='?_src_=vars;remlanguage=\ref[D]'>Remove Language</option>"
			body += "<option value='?_src_=vars;addorgan=\ref[D]'>Add Organ</option>"
			body += "<option value='?_src_=vars;remorgan=\ref[D]'>Remove Organ</option>"
			body += "<option value='?_src_=vars;addlimb=\ref[D]'>Add Limb</option>"
			body += "<option value='?_src_=vars;remlimb=\ref[D]'>Remove Limb</option>"

			body += "<option value='?_src_=vars;fix_nano=\ref[D]'>Fix NanoUI</option>"

			body += "<option value='?_src_=vars;addverb=\ref[D]'>Add Verb</option>"
			body += "<option value='?_src_=vars;remverb=\ref[D]'>Remove Verb</option>"
			if(ishuman(D))
				body += "<option value>---</option>"
				body += "<option value='?_src_=vars;edit_skill=\ref[D]'>Edit Skills</option>"
				body += "<option value='?_src_=vars;setmutantrace=\ref[D]'>Set Mutantrace</option>"
				body += "<option value='?_src_=vars;setspecies=\ref[D]'>Set Species</option>"
				body += "<option value='?_src_=vars;makeai=\ref[D]'>Make AI</option>"
				body += "<option value='?_src_=vars;makerobot=\ref[D]'>Make cyborg</option>"
				body += "<option value='?_src_=vars;makemonkey=\ref[D]'>Make monkey</option>"
				body += "<option value='?_src_=vars;makealien=\ref[D]'>Make alien</option>"
			if(isXeno(D))
				body += "<option value='?_src_=vars;changehivenumber=\ref[D]'>Change Hivenumber</option>"
			body += "<option value>---</option>"
			body += "<option value='?_src_=vars;gib=\ref[D]'>Gib</option>"
		if(isobj(D))
			body += "<option value='?_src_=vars;delall=\ref[D]'>Delete all of type</option>"
		if(isobj(D) || ismob(D) || isturf(D))
			body += "<option value='?_src_=vars;explode=\ref[D]'>Trigger explosion</option>"
			body += "<option value='?_src_=vars;emp=\ref[D]'>Trigger EM pulse</option>"

		body += "</select></form>"

		body += "</div></td></tr></table></div><hr>"

		body += "<font size='1'><b>E</b> - Edit, tries to determine the variable type by itself.<br>"
		body += "<b>C</b> - Change, asks you for the var type first.<br>"
		body += "<b>M</b> - Mass modify: changes this variable for all objects of this type.</font><br>"

		body += "<hr><table width='100%'><tr><td width='20%'><div align='center'><b>Search:</b></div></td><td width='80%'><input type='text' id='filter' name='filter_text' value='' style='width:100%;'></td></tr></table><hr>"

		body += "<ol id='vars'>"

		var/list/names = list()
		for (var/V in D.vars)
			names += V

		names = sortList(names)

		for (var/V in names)
			body += debug_variable(V, D.vars[V], 0, D)

		body += "</ol>"

		var/html = "<html><head>"
		if (title)
			html += "<title>[title]</title>"
		html += {"<style>
	body
	{
		font-family: Verdana, sans-serif;
		font-size: 9pt;
	}
	.value
	{
		font-family: "Courier New", monospace;
		font-size: 8pt;
	}
	</style>"}
		html += "</head><body>"
		html += body

		html += {"
			<script type='text/javascript'>
				var vars_ol = document.getElementById("vars");
				var complete_list = vars_ol.innerHTML;
			</script>
		"}

		html += "</body></html>"

		usr << browse(html, "window=variables\ref[D];size=475x650")

		return

	proc/debug_variable(name, value, level, var/datum/DA = null)
		var/html = ""

		if(DA)
			html += "<li style='backgroundColor:white'>(<a href='?_src_=vars;datumedit=\ref[DA];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;datumchange=\ref[DA];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;datummass=\ref[DA];varnamemass=[name]'>M</a>) "
		else
			html += "<li>"

		if (isnull(value))
			html += "[name] = <span class='value'>null</span>"

		else if (istext(value))
			html += "[name] = <span class='value'>\"[value]\"</span>"

		else if (isicon(value))
			#ifdef VARSICON
			var/icon/I = new/icon(value)
			var/rnd = rand(1,10000)
			var/rname = "tmp\ref[I][rnd].png"
			usr << browse_rsc(I, rname)
			html += "[name] = (<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
			#else
			html += "[name] = /icon (<span class='value'>[value]</span>)"
			#endif

/*		else if (istype(value, /image))
			#ifdef VARSICON
			var/rnd = rand(1, 10000)
			var/image/I = value

			src << browse_rsc(I.icon, "tmp\ref[value][rnd].png")
			html += "[name] = <img src=\"tmp\ref[value][rnd].png\">"
			#else
			html += "[name] = /image (<span class='value'>[value]</span>)"
			#endif
*/
		else if (isfile(value))
			html += "[name] = <span class='value'>'[value]'</span>"

		else if (istype(value, /datum))
			var/datum/D = value
			html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

		else if (istype(value, /client))
			var/client/C = value
			html += "<a href='?_src_=vars;Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
	//
		else if (istype(value, /list))
			var/list/L = value
			html += "[name] = /list ([L.len])"

			if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
				// not sure if this is completely right...
				if(0)   //(L.vars.len > 0)
					html += "<ol>"
					html += "</ol>"
				else
					html += "<ul>"
					var/index = 1
					for (var/entry in L)
						if(istext(entry))
							html += debug_variable(entry, L[entry], level + 1)
						//html += debug_variable("[index]", L[index], level + 1)
						else
							html += debug_variable(index, L[index], level + 1)
						index++
					html += "</ul>"

		else
			html += "[name] = <span class='value'>[value]</span>"

		html += "</li>"

		return html

/client/proc/view_var_Topic(href, href_list, hsrc)
	//This should all be moved over to datum/admins/Topic() or something ~Carn
	if( (usr.client != src) || !src.holder )
		return
	if(href_list["Vars"])
		debug_variables(locate(href_list["Vars"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_VAREDIT))	return

		var/mob/M = locate(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/new_name = stripped_input(usr,"What would you like to name this mob?","Input a name",M.real_name,MAX_NAME_LEN)
		if( !new_name || !M )	return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.fully_replace_character_name(M.real_name,new_name)
		href_list["datumrefresh"] = href_list["rename"]

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locate(href_list["datumedit"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnameedit"], 1)

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locate(href_list["datumchange"])
		if(!istype(D,/datum) && !istype(D,/client))
			to_chat(usr, "This can only be used on instances of types /client or /datum")
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/A = locate(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom")
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])

	else if(href_list["mob_player_panel"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.holder.show_player_panel(M)
		href_list["datumrefresh"] = href_list["mob_player_panel"]

	else if(href_list["give_spell"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/M = locate(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_spell(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["give_disease"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/M = locate(href_list["give_disease"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.give_disease(M)
		href_list["datumrefresh"] = href_list["give_spell"]

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/M = locate(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_godmode(M)
		href_list["datumrefresh"] = href_list["godmode"]

	else if(href_list["gib"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		src.cmd_admin_gib(M)

	else if(href_list["drop_everything"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locate(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["make_skeleton"])
		if(!check_rights(R_FUN))	return

		var/mob/living/carbon/human/H = locate(href_list["make_skeleton"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		H.makeSkeleton()
		href_list["datumrefresh"] = href_list["make_skeleton"]

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))	return

		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj")
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?",,"Strict type","Type and subtypes","Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?",,"Yes","No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?",,"Yes","No") != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in object_list)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
				message_admins("\blue [key_name(usr)] deleted all objects of type [O_type] ([i] objects deleted) ")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in object_list)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
				log_admin("[key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")
				message_admins("\blue [key_name(usr)] deleted all objects of type or subtype of [O_type] ([i] objects deleted) ")

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_FUN))	return

		var/atom/A = locate(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_explosion(A)
		href_list["datumrefresh"] = href_list["explode"]

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_FUN))	return

		var/atom/A = locate(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf")
			return

		src.cmd_admin_emp(A)
		href_list["datumrefresh"] = href_list["emp"]

	else if(href_list["mark_object"])
		if(!check_rights(0))	return

		var/datum/D = locate(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum")
			return

		src.holder.marked_datum = D
		href_list["datumrefresh"] = href_list["mark_object"]

	else if(href_list["rotatedatum"])
		if(!check_rights(0))	return

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")	A.dir = turn(A.dir, -45)
			if("left")	A.dir = turn(A.dir, 45)
		href_list["datumrefresh"] = href_list["rotatedatum"]

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makealien"=href_list["makealien"]))

	else if(href_list["changehivenumber"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/living/carbon/Xenomorph/X = locate(href_list["changehivenumber"])
		if(!istype(X))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/Xenomorph")
			return
		var/hivenumber_status = X.hivenumber
		var/list/namelist = list("Normal","Corrupted","Alpha","Beta","Zeta")

		var/newhive = input(src,"Select a hive.", null, null) in namelist

		if(!X)
			to_chat(usr, "This xeno no longer exists")
			return
		var/newhivenumber
		switch(newhive)
			if("Normal")
				newhivenumber = XENO_HIVE_NORMAL
			if("Corrupted")
				newhivenumber = XENO_HIVE_CORRUPTED
			if("Alpha")
				newhivenumber = XENO_HIVE_ALPHA
			if("Beta")
				newhivenumber = XENO_HIVE_BETA
			if("Zeta")
				newhivenumber = XENO_HIVE_ZETA
		if(X.hivenumber != hivenumber_status)
			to_chat(usr, "Someone else changed this xeno while you were deciding")
			return

		holder.Topic(href, list("changehivenumber"=href_list["changehivenumber"],"newhivenumber"=newhivenumber))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")	return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["setmutantrace"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["setmutantrace"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_mutantrace = input("Please choose a new mutantrace","Mutantrace",null) as null|anything in list("NONE","golem","lizard","slime","plant","shadow","tajaran","skrell","vox")
		switch(new_mutantrace)
			if(null)
				return
			if("NONE")
				new_mutantrace = ""
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(H.dna)
			H.dna.mutantrace = new_mutantrace
			H.update_mutantrace()

	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_species = input("Please choose a new species.","Species",null) as null|anything in all_species

		if(!new_species) return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.set_species(new_species))
			to_chat(usr, "Set species of [H] to [H.species].")
		else
			to_chat(usr, "Failed! Something went wrong.")

	else if(href_list["edit_skill"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["edit_skill"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(!H.mind)
			to_chat(usr, "This can't be used on humans without a mind.")
			return

		if(!H.mind.cm_skills)
			H.mind.cm_skills = new /datum/skills/pfc()

		var/selected_skill = input("Please choose a skill to edit.","Skills",null) as null|anything in list("cqc","endurance","engineer", "construction","firearms", "pistols", "rifles", "smgs", "shotguns", "heavy_weapons","smartgun","spec_weapons","leadership","medical", "surgery","melee_weapons","pilot","police","powerloader")
		if(!selected_skill)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!H.mind)
			to_chat(usr, "Mob lost its mind.")
			return

		var/new_skill_level = input("Select a new level for the [selected_skill] skill ","New Skill Level") as null|num
		if(isnull(new_skill_level))
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!H.mind)
			to_chat(usr, "Mob lost its mind.")
			return

		switch(selected_skill)
			if("cqc")
				H.mind.cm_skills.cqc = new_skill_level
			if("melee_weapons")
				H.mind.cm_skills.melee_weapons = new_skill_level
			if("firearms")
				H.mind.cm_skills.firearms = new_skill_level
			if("pistols")
				H.mind.cm_skills.pistols = new_skill_level
			if("rifles")
				H.mind.cm_skills.rifles = new_skill_level
			if("smgs")
				H.mind.cm_skills.smgs = new_skill_level
			if("shotguns")
				H.mind.cm_skills.shotguns = new_skill_level
			if("heavy_weapons")
				H.mind.cm_skills.heavy_weapons = new_skill_level
			if("smartgun")
				H.mind.cm_skills.smartgun = new_skill_level
			if("spec_weapons")
				H.mind.cm_skills.spec_weapons = new_skill_level
			if("leadership")
				H.mind.cm_skills.leadership = new_skill_level
			if("medical")
				H.mind.cm_skills.medical = new_skill_level
			if("surgery")
				H.mind.cm_skills.surgery = new_skill_level
			if("pilot")
				H.mind.cm_skills.pilot = new_skill_level
			if("endurance")
				H.mind.cm_skills.endurance = new_skill_level
			if("engineer")
				H.mind.cm_skills.engineer = new_skill_level
			if("construction")
				H.mind.cm_skills.construction = new_skill_level
			if("police")
				H.mind.cm_skills.police = new_skill_level
			if("powerloader")
				H.mind.cm_skills.powerloader = new_skill_level
		
		H.update_action_buttons()

		to_chat(usr, "[H]'s [selected_skill] skill is now set to [new_skill_level].")


	else if(href_list["addlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locate(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		var/new_language = input("Please choose a language to add.","Language",null) as null|anything in all_languages

		if(!new_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].")
		else
			to_chat(usr, "Mob already knows that language.")

	else if(href_list["remlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locate(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return

		if(!H.languages.len)
			to_chat(usr, "This mob knows no languages.")
			return

		var/datum/language/rem_language = input("Please choose a language to remove.","Language",null) as null|anything in H.languages

		if(!rem_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].")
		else
			to_chat(usr, "Mob doesn't know that language.")

	else if(href_list["addverb"])
		if(!check_rights(R_DEBUG))      return

		var/mob/living/H = locate(href_list["addverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living")
			return
		var/list/possibleverbs = list()
		possibleverbs += "Cancel" 								// One for the top...
		possibleverbs += typesof(/mob/proc,/mob/verb,/mob/living/proc,/mob/living/verb)
		switch(H.type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc,/mob/living/carbon/verb,/mob/living/carbon/human/verb,/mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/robot/proc,/mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/ai/proc,/mob/living/silicon/ai/verb)
		possibleverbs -= H.verbs
		possibleverbs += "Cancel" 								// ...And one for the bottom

		var/verb = input("Select a verb!", "Verbs",null) as anything in possibleverbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb || verb == "Cancel")
			return
		else
			H.verbs += verb

	else if(href_list["remverb"])
		if(!check_rights(R_DEBUG))      return

		var/mob/H = locate(href_list["remverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		var/verb = input("Please choose a verb to remove.","Verbs",null) as null|anything in H.verbs
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!verb)
			return
		else
			H.verbs -= verb

	else if(href_list["addorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locate(href_list["addorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/new_organ = input("Please choose an organ to add.","Organ",null) as null|anything in subtypesof(/datum/internal_organ)

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(locate(new_organ) in M.internal_organs)
			to_chat(usr, "Mob already has that organ.")
			return

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/datum/internal_organ/I = new new_organ(H)

			var/organ_slot = input(usr, "Which slot do you want the organ to go in ('default' for default)?")  as text|null

			if(!organ_slot)
				return

			if(organ_slot != "default")
				organ_slot = sanitize(copytext(organ_slot,1,MAX_MESSAGE_LEN))
			else
				if(I.removed_type)
					var/obj/item/organ/O = new I.removed_type()
					organ_slot = O.organ_tag
					qdel(O)
				else
					organ_slot = "unknown organ"

			if(H.internal_organs_by_name[organ_slot])
				to_chat(usr, "[H] already has an organ in that slot.")
				qdel(I)
				return

			H.internal_organs_by_name[organ_slot] = I
			to_chat(usr, "Added new [new_organ] to [H] as slot [organ_slot].")
		else
			new new_organ(M)
			to_chat(usr, "Added new [new_organ] to [M].")

	else if(href_list["remorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locate(href_list["remorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon")
			return

		var/rem_organ = input("Please choose an organ to remove.","Organ",null) as null|anything in M.internal_organs

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		if(!(locate(rem_organ) in M.internal_organs))
			to_chat(usr, "Mob does not have that organ.")
			return

		to_chat(usr, "Removed [rem_organ] from [M].")
		qdel(rem_organ)


	else if(href_list["addlimb"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/M = locate(href_list["addlimb"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/new_limb = input("Please choose an organ to add.","Organ",null) as null|anything in subtypesof(/datum/limb)

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		var/datum/limb/EO = locate(new_limb) in M.limbs
		if(!EO)
			return
		if(!(EO.status & LIMB_DESTROYED))
			to_chat(usr, "Mob already has that organ.")
			return

		EO.status = NOFLAGS
		EO.perma_injury = 0
		EO.germ_level = 0
		EO.reset_limb_surgeries()
		M.update_body(0)
		M.updatehealth()
		M.UpdateDamageIcon()

	else if(href_list["remlimb"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/M = locate(href_list["remlimb"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/rem_limb = input("Please choose a limb to remove.","Organ",null) as null|anything in M.limbs

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		var/datum/limb/EO = locate(rem_limb) in M.limbs
		if(!EO)
			return
		if(EO.status & LIMB_DESTROYED)
			to_chat(usr, "Mob doesn't have that limb.")
			return
		EO.droplimb(1)


	else if(href_list["fix_nano"])
		if(!check_rights(R_DEBUG)) return

		var/mob/H = locate(href_list["fix_nano"])

		if(!istype(H) || !H.client)
			to_chat(usr, "This can only be done on mobs with clients")
			return

		nanomanager.send_resources(H.client)

		to_chat(usr, "Resource files sent")
		to_chat(H, "Your NanoUI Resource files have been refreshed")

		log_admin("[key_name(usr)] resent the NanoUI resource files to [key_name(H)] ")

	else if(href_list["regenerateicons"])
		if(!check_rights(0))	return

		var/mob/M = locate(href_list["regenerateicons"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob")
			return
		M.regenerate_icons()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_FUN))	return

		var/mob/living/L = locate(href_list["mobToDamage"])
		if(!istype(L)) return

		var/Text = href_list["adjustDamage"]

		var/amount =  input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore")
			return

		switch(Text)
			if("brute")	L.adjustBruteLoss(amount)
			if("fire")	L.adjustFireLoss(amount)
			if("toxin")	L.adjustToxLoss(amount)
			if("oxygen")L.adjustOxyLoss(amount)
			if("brain")	L.adjustBrainLoss(amount)
			if("clone")	L.adjustCloneLoss(amount)
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]")
				return
		L.updatehealth()

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [L] ")
			message_admins("\blue [key_name(usr)] dealt [amount] amount of [Text] damage to [L] ")
			href_list["datumrefresh"] = href_list["mobToDamage"]

	if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(!istype(DAT, /datum))
			return
		src.debug_variables(DAT)

	return

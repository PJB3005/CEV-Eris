/datum/asset/nanoui
	isTrivial = FALSE
	var/list/common = list()

	var/list/common_dirs = list(
		"nano/css/",
		"nano/images/",
		"nano/images/status_icons/",
		"nano/images/modular_computers/",
		"nano/js/"
	)
	var/list/uncommon_dirs = list(
		"nano/templates/",
		"news_articles/images/"
	)

/datum/asset/nanoui/register()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])
	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) == "/")
				continue // Ignore directories.

			if(!fexists(path + filename))
				continue

			register_asset(filename, fcopy_rsc(path + filename))

			if (copytext(filename, length(filename) - 4) == ".tmpl")
				// This is a template file.
				var/js_wrap = generate_js_wrap(file2text(path + filename))
				register_asset(filename + ".js", js_wrap)

	var/list/mapnames = list()
	for(var/z in maps_data.station_levels)
		mapnames += map_image_file_name(z)

	var/list/filenames = flist(MAP_IMAGE_PATH)
	for(var/filename in filenames)
		if(copytext(filename, length(filename)) != "/") // Ignore directories.
			var/file_path = MAP_IMAGE_PATH + filename
			if((filename in mapnames) && fexists(file_path))
				common[filename] = fcopy_rsc(file_path)
				register_asset(filename, common[filename])

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon, FALSE)
	send_asset_list(client, common, TRUE)

/var/CHAR_CARRIAGE_RETURN = ascii2text(0x0D)
/var/CHAR_TAB = ascii2text(0x09)

/datum/asset/nanoui/proc/generate_js_wrap(var/text)
	var/list/out = list()
	for (var/i = 1 to length(text))
		var/c = text[i]
		if (c == CHAR_CARRIAGE_RETURN)
			out += "\\r"
		else if (c == CHAR_TAB)
			out += "\\t"
		else
			switch (c)
				if ("\n")
					out += "\\n"
				if ("'")
					out += "\\'"
				if ("\"")
					out += "\\\""
				if ("\\")
					out += "\\\\"
				else
					out += c

	return jointext(out, "")
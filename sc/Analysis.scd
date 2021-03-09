////////////////////////////////////////////////////////////////
//
//                  SNDArchive - Analysis
//
////////////////////////////////////////////////////////////////

(
	var analysis = ();

	analysis.onboard = { };

	analysis.analyse = {|ev, n, db, folder, name|

		var processes = [ [\Tartini], [\SpecCentroid] ];
	    var processNames = ["\"tartini\"","\"spectralCentroid\""];
    	var map=Array.newClear(processes.size), output=Array.newClear(processes.size);
	    var segments, features, buf, scmir;
	    var path = folder ++ name;

		// Read and analyse
		buf = Buffer.read(s, path);
		scmir = SCMIRAudioFile(path, processes);
		scmir.extractFeatures(normalize:true); // TODO: Make optional
		scmir.extractOnsets(threshold:0.4); // TODO: Make optionals
		s.sync;

		// Set end position for the segments
		segments = scmir.onsetdata.collect{|pos,i|
			var n=i+1; if(n<scmir.onsetdata.size,
			{[pos,scmir.onsetdata[n]]}, {[pos,buf.duration]});
		};

		// Run it twice for averaging to segment number
		2.do {features=scmir.gatherFeaturesBySegments(segments, summarytype:0)};

		" ## Feature and segment size:".postln;
		features.size.postln; segments.size.postln;

		processes.size.do{|i|
			map[i] = features.unlace(2)[i];
			output[i] = map[i].sum / map[i].size;
		};

		// Update the Sound with the average stats
		db.sendMsg(SNDArchive.send, "sound", n, name, processNames.asString, output.asString);

		// Create the Segments, one by one
		segments.do{|segment, i|
			var keys = List(), values = List();
		    keys.add("\"index\""); values.add(i);
			keys.add("\"start\""); values.add(segment[0]);
			keys.add("\"end\""); values.add(segment[1]);
			keys.add("\"tartini\""); values.add(map[0][i]);
			keys.add("\"spectralCentroid\""); values.add(map[1][i]);
			db.sendMsg(SNDArchive.send, "segment", n, name, keys.asArray.asString, values.asArray.asString);
		};

	    ("## Analysis Complete:" + name).postln;
	};

	analysis.run = {|ev|

	    var folder = ev.archive.sndPath;

		// Register the analysis responder
		OSCdef(\find, {|msg|
			var sounds = msg[1].asString.split($,);

		    "## Analysis run".postln;

			{
				sounds.do{|it|
					if(it.asString.endsWith(".wav"), {
					var parts = it.split($/);
					var file = parts[parts.size-1];
					var filefolder = folder;
					parts.do{|part| filefolder = filefolder ++ "/" ++ part};
					ev.analyse(ev.archive.name, ev.archive.db, filefolder.replace(file,""), file); s.sync;
					})
				}
			}.fork

	    }, "/sndarchive");


		// Call the db to Find sounds in a folder
		ev.archive.db.sendMsg(SNDArchive.send, "findAll", ev.archive.name);
	}
)
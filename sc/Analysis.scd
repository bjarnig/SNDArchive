////////////////////////////////////////////////////////////////
//
//                  SNDArchive - Analysis
//
////////////////////////////////////////////////////////////////

(
	var analysis = ();

	analysis.onboard = { };

	analysis.analyse = {|ev, n, db, folder, name|

	var processes = List [ [\Tartini], [\SpecCentroid], [\SpectralEntropy], [\SpecFlatness], [\Loudness], [\FFTSpread], [\SensoryDissonance], [\Transient]];
	    var processNames = List ["\"tartini\"","\"spectralCentroid\"","\"spectralEntropy\"","\"specFlatness\"", "\"loudness\"", "\"fFTSpread\"", "\"sensoryDissonance\"", "\"transient\""];
	var map=List(), output=List();
	    var segments, features, buf, scmir;
	    var path = folder ++ name;

		// Read and analyse
		buf = Buffer.read(s, path);
		scmir = SCMIRAudioFile(path, processes);
		scmir.extractFeatures(normalize:true); // TODO: Make optional
		scmir.extractOnsets(threshold:0.6); // TODO: Make optionals
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
		    map.add(features.unlace(8)[i]);
		    output.add(map[i].sum / map[i].size);
		};

		// Add sound duration
		processNames.add("\"duration\""); output.add(buf.duration);
		processNames.asString.postln; output.asString;

		// Update the Sound with the average stats
	   	db.sendMsg(SNDArchive.send, "sound", n, name, processNames.asArray.asString, output.asString);

		// Create the Segments, one by one
		segments.do{|segment, i|
			var keys = List(), values = List();
			keys.add("\"index\""); values.add(i);
			keys.add("\"start\""); values.add(segment[0]);
			keys.add("\"end\""); values.add(segment[1]);
			keys.add("\"duration\""); values.add(segment[1] - segment[0]);
			keys.add("\"tartini\""); values.add(map[0][i]);
			keys.add("\"spectralCentroid\""); values.add(map[1][i]);
			keys.add("\"spectralEntropy\""); values.add(map[2][i]);
			keys.add("\"specFlatness\""); values.add(map[3][i]);
			keys.add("\"loudness\""); values.add(map[4][i]);
			keys.add("\"fFTSpread\""); values.add(map[5][i]);
			keys.add("\"sensoryDissonance\""); values.add(map[6][i]);
			keys.add("\"transient\""); values.add(map[7][i]);
			db.sendMsg(SNDArchive.send, "segment", n, name, keys.asArray.asString, values.asArray.asString);
		}; 

	    ("## Analysis Complete:" + name).postln;
	};

	analysis.run = {|ev|

	    var folder = ev.archive.sndPath;

		// Register the analysis responder
		OSCdef(\find, {|msg|
			var sounds = msg[1].asString.split($,);

		    "## Analysis run".postln; sounds.postln;

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
		ev.archive.db.sendMsg(SNDArchive.send, "allSounds", ev.archive.name);
	}
)
SNDArchive {

	var <>sndPath;
	var <>libPath;
	var <>analysis;
	var <>reconstruct;
	var <>queries;
	var <>db;

    *new { |interpreter,sounds="/Users/bjarni/Works/Adapt/Upic-Observe/material/source/saturday/",lib|

		var instance;

		if(lib.notNil, {
			instance = super.newCopyArgs(sounds, lib)
		}, {
			instance = super.newCopyArgs(sounds, Platform.userExtensionDir ++ "/Dev/SNDArchive/sc/")
		});

		instance.analysis = interpreter.compileFile(instance.libPath ++ "Analysis.scd").value;
		instance.reconstruct = interpreter.compileFile(instance.libPath ++ "Reconstruct.scd").value;
		instance.queries = interpreter.compileFile(instance.libPath ++ "Queries.scd").value;

		{
			// Address of the Node program
			instance.db = NetAddr("127.0.0.1", 57121);

			// Clear DBs
			instance.db.sendMsg("/sndarchive", "clear", "o");

			0.1.wait;

			// Construct DB
			instance.db.sendMsg("/sndarchive", "scan", instance.sndPath);

	    }.fork

		^instance;
	}

	start {

		"## run".postln;

	}
}

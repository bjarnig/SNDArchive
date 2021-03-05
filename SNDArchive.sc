SNDArchive {

	// Constants
	classvar <>send = "/sndarchive";
	classvar <>receive = "\sndarchive";

	// Members
	var <>sndPath;
	var <>libPath;
	var <>address;
	var <>port;
	var <>name;
	var <>analysis;
	var <>reconstruct;
	var <>queries;
	var <>db;
	var <>items;

	// Construtctor & Init
    *new {|
		interpreter,
		sounds="/Users/bjarni/Works/Adapt/Upic-Observe/material/source/saturday/",
		lib,address="127.0.0.1",port=57121,dbname="sndarchive"|

		var instance;

		if(lib.notNil, {
			instance = super.newCopyArgs(sounds, lib, address, port, dbname)
		}, {
			instance = super.newCopyArgs(sounds, Platform.userExtensionDir++"/Dev/SNDArchive/sc/", address, port, dbname)
		});

		^instance.init(interpreter);
	}

	init{|interpreter|

		this.analysis = interpreter.compileFile(this.libPath ++ "Analysis.scd").value;
		this.reconstruct = interpreter.compileFile(this.libPath ++ "Reconstruct.scd").value;
		this.queries = interpreter.compileFile(this.libPath ++ "Queries.scd").value;
		this.analysis.archive = this; this.reconstruct.archive = this; this.queries.archive = this;

		{
			// Address of the Node program
			this.db = NetAddr(this.address, this.port);

			// Init DBs
			this.db.sendMsg(SNDArchive.send, "clearInit", this.name); 0.1.wait;

			// Construct DB
			this.db.sendMsg(SNDArchive.send, "scan",  this.name, this.sndPath);

	    }.fork

		^this;
	}

	add{|segments,name="query"|

		if(this.items.isNil, { this.items = Dictionary() });

		this.items[name] = segments;
		this.reconstruct.loadBuffers(segments);
	}
}

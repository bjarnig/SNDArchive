SNDArchive {

	classvar <>send = "/sndarchive";
	classvar <>receive = "\sndarchive";

	var <>sndPath;
	var <>libPath;
	var <>address;
	var <>port;
	var <>name;
	var <>analysis;
	var <>reconstruct;
	var <>queries;
	var <>extend;
	var <>db;
	var <>items;
	var <>buffers;

    *new {|
		interpreter,
		sounds="/Users/bjarni/Works/Adapt/Upic-Observe/material/source/saturday/",
		lib,address="127.0.0.1",port=57121,dbname="sndarchive"|

		var instance;

		if(lib.notNil, {
			instance = super.newCopyArgs(sounds, lib, address, port, dbname)
		}, {
			instance = super.newCopyArgs(sounds, thisMethod.filenameSymbol.asString.replace("SNDArchive.sc", "sc/"),
			address, port, dbname)
		});

		^instance.init(interpreter);
	}

	init {|interpreter|
		this.buffers = Dictionary(); this.items = Dictionary();
		this.analysis = interpreter.compileFile(this.libPath ++ "Analysis.scd").value;
		this.reconstruct = interpreter.compileFile(this.libPath ++ "Reconstruct.scd").value;
		this.queries = interpreter.compileFile(this.libPath ++ "Queries.scd").value;
		this.extend = interpreter.compileFile(this.libPath ++ "Extend.scd").value;
		this.analysis.archive = this; this.reconstruct.archive = this; this.queries.archive = this;
    this.db = NetAddr(this.address, this.port);
		this.db.sendMsg(SNDArchive.send, "init", this.name);
		^this;
	}

	create {
		{
			this.db.sendMsg(SNDArchive.send, "clearInit", this.name); 0.1.wait;
			this.db.sendMsg(SNDArchive.send, "scan",  this.name, this.sndPath)
		}.fork
	}

	refresh {|interpreter|
		this.analysis = interpreter.compileFile(this.libPath ++ "Analysis.scd").value;
		this.reconstruct = interpreter.compileFile(this.libPath ++ "Reconstruct.scd").value;
		this.queries = interpreter.compileFile(this.libPath ++ "Queries.scd").value;
		this.extend = interpreter.compileFile(this.libPath ++ "Extend.scd").value;
		this.analysis.archive = this; this.reconstruct.archive = this; this.queries.archive = this;
	}

	analyse {
		this.analysis.run();
	}

	reconstructions {
		this.reconstruct.keys.do{|key| key.postln}; ^this.reconstruct
	}

	add {|segments,name="query"|

		if(this.items.isNil, { this.items = Dictionary() });

		this.items[name] = segments;
		this.loadBuffers(segments);
	}

	loadBuffers {|sounds|

		{
			sounds.do{|seg|

				if(this.buffers[seg.path].isNil, {
					var buf = Buffer.read(Server.default, seg.path);
					Server.default.sync; this.buffers[seg.path] = buf;
				})
			};

			(" ## Completed loading buffers:" + this.buffers.keys.size).postln;

		}.fork;
	}

}

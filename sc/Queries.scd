////////////////////////////////////////////////////////////////
//
//                  SNDArchive - Queries
//
////////////////////////////////////////////////////////////////

(
	var queries = ();

	queries.convert = {|ev, pr|
		(
			\index : pr[0].asString.asInteger,
			\start : pr[1].asString.asFloat,
			\end : pr[2].asString.asFloat,
			\path : pr[3].asString.replace("\"","").replace("]","")
		)
	};

    queries.registerFind = {|ev, name|
		OSCdef(\find, {|msg|
		    var result = msg[1].asString.replace("],","").split($[);
		    var segments = result.collect({|result|queries.convert(result.split($,));
			}).reject{|element| File.exists(element.path).not };
		    ev.archive.add(segments, name)
		}, SNDArchive.send);
    };

    queries.find = {|ev, method="topSegments", param="start", limit=15, name="query"|
	    var n = ev.archive.name, db = ev.archive.db;
	    ev.registerFind(name);
	    db.sendMsg("/"++SNDArchive.receive, method, n, param, limit); ev
	};

	queries.range = {|ev, method="topRangeSegments", param="start", limit=15, from=0.0, to=1.0, name="query"|
	    var n = ev.archive.name, db = ev.archive.db;
    	ev.registerFind(name);
	    db.sendMsg("/"++SNDArchive.receive, method, n, param, limit, from, to); ev
	};

    queries.findBySound = {|ev, method="topSegBySound", param="start", sound="", limit=15, name="query"|
	    var n = ev.archive.name, db = ev.archive.db;
	    ev.registerFind(name);
	    db.sendMsg("/"++SNDArchive.receive, method, n, param, sound, limit); ev
	};

    queries.combine = {|ev, seqa, seqb, result|
	    ev.archive.items[result] = (ev.archive.items[seqa] ++ ev.archive.items[seqb]).asSet.asArray
	};

    queries.join = {|ev, seqa, seqb, result|
	    ev.archive.items[result] = ev.archive.items[seqa] ++ ev.archive.items[seqb];
	};

    queries.common = {|ev, seqa, seqb, result|
    	ev.archive.items[result] = union(ev.archive.items[seqa], ev.archive.items[seqa])
	};

    queries.intersection = {|ev, seqa, seqb, result|
    	ev.archive.items[result] = sect(ev.archive.items[seqa], ev.archive.items[seqa])
	};

    queries.diff = {|ev, seqa, seqb, result|
    	ev.archive.items[result] = difference(ev.archive.items[seqa], ev.archive.items[seqa])
	};

	queries
)
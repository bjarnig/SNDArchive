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
			\path : pr[3].asString.replace("\"","")
		)
	};

    queries.find = {|ev, method="findTop", param="start", limit=15, name="query"|

	    var n = ev.archive.name, db = ev.archive.db;

		OSCdef(\find, {|msg|
			    var result = msg[1].asString.replace("],","").split($[);
			    var segments = result.collect({|result|queries.convert(result.split($,));
			}).reject{|element| File.exists(element.path).not };
		    ev.archive.add(segments, name)
		}, SNDArchive.send);

	    db.sendMsg("/"++SNDArchive.receive, method, n, param, limit); ev
	};

	queries
)
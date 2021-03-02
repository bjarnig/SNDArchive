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

	queries.find = {|ev, obj, method="findTop", param="start", limit=15|

	var n = obj.name, db = obj.db;

		OSCdef(\find, {|msg|

			var result = msg[1].asString.replace("],","").split($[);
			var segments = result.collect({|result|queries.convert(result.split($,))
			}).reject{|element| File.exists(element.path).not };

		    // TODO: move this!
		    if(obj.items.isNil, {  obj.items = List() });
		    obj.items.add(segments);
		    obj.reconstruct.loadBuffers(segments);

		}, "\sndarchive");

		db.sendMsg("/sndarchive", method, n, param, limit)
	};

	queries
)
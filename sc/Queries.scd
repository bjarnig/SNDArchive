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

	queries.find = {|ev, db, method="findTop", param="start", limit=15, cb|

		OSCdef(\find, {|msg|

			var result = msg[1].asString.replace("],","").split($[);
			var segments = result.collect({|result|queries.convert(result.split($,))
			}).reject{|element| File.exists(element.path).not };

			cb.(segments)

		}, "\sndarchive");

		db.sendMsg("/sndarchive", method, param, limit)
	};

	queries
)
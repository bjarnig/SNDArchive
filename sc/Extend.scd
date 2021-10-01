////////////////////////////////////////////////////////////////
//
//                SNDArchive - Reconstruct
//
////////////////////////////////////////////////////////////////

(

var extend = ();

extend.linen = {|ev,nodes|

	Tdef(\tf, {

		nodes.do{|node|
			node.play;
			rrand(3,8).wait;
		};

		rrand(6,9).wait;

		nodes.do{|node|
			node.stop;
			rrand(2,3).wait;
		};

	}).play

};

extend.offset = {|ev,nodes|

	Tdef(\tf, {

		nodes.do{|node|
			node.play;
			rrand(3,8).wait;
		};

	}).play

};

extend

)
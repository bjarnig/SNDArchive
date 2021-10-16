////////////////////////////////////////////////////////////////
//
//                SNDArchive - Extend
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

extend.offset = {|ev,nodes, duration=32|

	Tdef(\tf, {

		nodes.do{|node|
			node.play;
			rrand(3,8).wait;
		};

		duration.wait;

		nodes.do{|node|
			node.stop;
			rrand(1,2).wait;
		};

	}).play

};

extend

)
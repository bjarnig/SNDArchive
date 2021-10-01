////////////////////////////////////////////////////////////////
//
//                SNDArchive - Reconstruct
//
////////////////////////////////////////////////////////////////

(

var extend = ();

extend.linen = {|ev,nodes,name|

	Tdef(\tf, {

		nodes.do{|node|
			node.play;
			rrand(2,4).wait;
		};

		rrand(6,8).wait;

		nodes.do{|node|
			node.stop;
			rrand(2,4).wait;
		};

	}).play

};

	extend
)
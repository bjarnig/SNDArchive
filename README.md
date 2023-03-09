
# SNDArchive
An expermental analysis frameworks for feature-based analysis (SCMIR) of sound files and reassembling of those through playback agents.

```javascript

/* Install SNDArchive */


Quarks.install("https://github.com/bjarnig/SNDArchive")

SND Archive requires, nodejs, sqlite and sequalize. 

npm install --save sqlite3

npm install --save sequelize

node db.js

// In case of large dbs the upd packet size needs to be increased
sudo sysctl -w net.inet.udp.maxdgram=65535



/* In SuperCollider  */

// Archive init
x = SNDArchive(this, Upics.path ++ "material/extracted", dbname:"upic-extracted");

// Creates the DB
x.create

// Analyse the sound
x.analyse


/*

  Select and reconstruct segments according to their properties

*/

// Lowest frequency per segment
x.queries.find("bottomSegments", "tartini", "14", "bseg");

// Normal playback
x.reconstruct.normal("bseg", \xra, 1, 1, 1, \grainSharp, inf).play

// Highest frequency per segment
x.queries.find("topSegments", "tartini", "14", "tseg");

// Normal playback
x.reconstruct.normal("tseg", \xra, 1, 1, 1, \grainSharp, inf).play

// A reconstruction
x.reconstruct.disc("bseg", \xrb, 1, 1, 1, \grainSharp, inf).play

// Alternate reconstruction
x.reconstruct.ringing("bseg", \xrc, 1, 1, 60, \trigItem2, inf).play

// Make a reconstruction that returns a Ndef and process further
(
x.reconstruct.normal("bseg", \sign, 1, 1, 1, \grainSharp, inf);
Ndef(\effect,{ CombC.ar(Ndef(\sign).ar, 0.2, 0.1, 2) }).play
)

// Refresh the dictionary code, one can modify it without recompiling
x.refresh(this)


/*

   Combine selections and multiple reconstructions

*/

// Top 12 segments of sensoryDissonance
x.queries.find("bottomSegments", "fFTSpread", "12", "sda");

// Top 18 segments of spectralEntropy
x.queries.find("topSegments", "spectralEntropy", "18", "sdb");

// Join the above two
x.queries.join("sda", "sdb", "sdc");

// Query the size
x.items["sdc"].size;

( // Multiple reconstructions

x.extend.linen(
	[
		x.reconstruct.dringmod("sdc", \xrb, 2, 1, 10, 2, \distsaw2),
		x.reconstruct.highsaw("sdc", \xrc),
		x.reconstruct.tartini("sda", \xra, 0.3, 1),
	], \cnstrct
)

)

x.reconstruct.dringmod("sdc", \xrb, 2, 1, 10, 2, \distsaw2).play
x.reconstruct.highsaw("sdc", \xrc).play
x.reconstruct.tartini("sda", \xra, 0.3, 1).play


/*

   Select sounds and synthesize based on their properties

*/

x.queries.find("topSounds", "transient", "6", "cca");
x.queries.find("bottomSegments", "duration", "17", "bseg");

(

x.extend.offset(
	[
		x.reconstruct.normal("cca", \ya, 0.5, 1, 1, \grainSharp, inf),
		x.reconstruct.ringing("bseg", \yb, 0.5, 1, 60, \trigItem2, inf),
		x.reconstruct.aggregate("bseg", \yc)
  ])

)

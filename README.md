
# SNDArchive
A small, expermental analysis frameworks for feature-based analysis of sound files and reassembling of those through playback agents.

```javascript

/* Install SNDArchive */

Quarks.install("https://github.com/bjarnig/SNDArchive")

SND Archive requires, nodejs, sqlite and sequalize. 

npm install --save sqlite3

npm install --save sequelize

node db.js

/* In SuperCollider  */

// First sound
x = SNDArchive(this, "/Users/bjarni/Works/Adapt/Upic-Observe/material/x", dbname:"salemx");

// Creates the DB
x.create

// Analyse the sound
x.analyse

// Execute queriess
x.queries.find("findBottom", "spectralCentroid", "8", "ma")
x.queries.find("findTop", "spectralCentroid", "2", "mb")
x.queries.find("findTop", "spectralCentroid", "3", "mc")

// Make a reconstruction that returns a Ndef
h = x.reconstruct.normal("ma", \blur); h.play

// Make a reconstruction that returns a Ndef and process further
(
x.reconstruct.normal(x.items["ma"], \sign);
Ndef(\effect,{ Greyhole.ar(Ndef(\sign).ar, 0.1, 0.95) }).play
)

// Refresh the dictionary code
x.refresh(this)

// Second sound (and db)
y = SNDArchive(this, "/Users/bjarni/Works/Adapt/Upic-Observe/material/y", dbname:"vox");
y.create
y.analyse
y.queries.find("findTop", "spectralCentroid", "4", "things")
y.reconstruct.tartini("things", \things); Ndef(\things).play
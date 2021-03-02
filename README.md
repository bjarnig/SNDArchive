
# SNDArchive
A small, expermental analysis frameworks for feature-based analysis of sound files and reassembling of those through playback agents.

```javascript

/* Install SNDArchive */

Quarks.install("https://github.com/bjarnig/SNDArchive")

SND Archive requires, nodejs, sqlite and sequalize. 

npm install --save sqlite3

npm install --save sequelize

node db.js

x = SNDArchive(this);
~snds = List();
x.analysis.run(x.db, x.sndPath);
x.queries.find(x.db, "findTop", "spectralCentroid", "9", {|result| result.postln; "cb!".postln; ~snds.add(result)})
x.reconstruct.loadBuffers(~snds[0])
x.reconstruct.normal(~snds[0])
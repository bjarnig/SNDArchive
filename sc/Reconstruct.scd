////////////////////////////////////////////////////////////////
//
//                SNDArchive - Reconstruct
//
////////////////////////////////////////////////////////////////

(
    var reconstruct = ();

	SynthDef(\grain, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0|
		var sig, shape, env, pos;
		shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		OffsetOut.ar(0, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\grainSharp, { |buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, olap=0.05|
		var sig, shape, env, pos;
		shape = Env([0, amp, amp, 0], [olap,dur,olap], \sine);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		OffsetOut.ar(0, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\sines, { |freq=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, olap=0.05|
		var sig, shape, env, pos;
		shape = Env.perc(releaseTime:0.3);
		env = EnvGen.ar(shape, doneAction: 2);
		sig = SinOsc.ar(freq,0,0.2);
		OffsetOut.ar(0, Pan2.ar(sig * env, pan));
	}).add;

    reconstruct.buffers = Dictionary();

	reconstruct.loadBuffers = {|ev,sounds|

		ev.buffers = Dictionary();

		{
			sounds.do{|seg|

				if(ev.buffers[seg.path].isNil, {
					var buf = Buffer.read(s, seg.path);
					s.sync; ev.buffers[seg.path] = buf;
				})
			};

			(" ## Completed loading buffers:" + ev.buffers.keys.size).postln;

		}.fork;
	};

	reconstruct.normal = {|ev,sounds|

		Routine({
			inf.do{
			sounds.do{|part, i|
				var buf = ev.buffers[part.path];
				var normlized = part.start / buf.duration; // normalize to 0 - 1
				var dur = part.end - part.start; // duration of the segment
				Synth(\grainSharp, [\dur, dur, \buf, buf, \start, normlized[0]]);
				dur.wait;
			}}
		}).play;
	};

reconstruct.strange = {|ev,sounds|

sounds = sounds.collect{|sound|ev.buffers[sound.path]};
sounds.postln;

SynthDef(\slot5, {
	|out=0, buf=0, amp=1, mod=9, rate=1, pos=0, pan=1.0, atk=0.01, dec=0.5, sus=1.0, rel=0.5, gate=1,filt=1000|
		var env, sig, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = HPF.ar(BBandStop.ar(PlayBuf.ar(1, buf, rate, 1, offset, 1).fold2([mod,mod*1.5]), filt, 8), 40) * 2;
		OffsetOut.ar(out, sig * env * amp);
	}).add();

{

Pdef(\sg,
Pbind(
	\instrument, \slot5,
	\amp, 2,
	\dur, Pn(Penv([0.2,0.3,0.04], [4,5])),
				\buf, Pseq(sounds,inf)
)).play;

2.wait;

Pdef(\sg2,
Pbind(
	\instrument, \slot5,
	\amp, 2,
	\dur, Pn(Penv([0.2,0.3,0.04], [4,5])),
	\buf, Pseq(sounds,inf)
)).play;

}.fork};

reconstruct.waffle = {|ev,sounds, name, mod=8, params|

var patName = ("pat" + name);
var output = Ndef(name, Pdef( patName )); sounds.postln;

SynthDef(\slot2, {
	|out=0, buf=0, amp=1, mod=9, rate=1, pos=0, pan=1.0, atk=0.01, dec=0.5, sus=1.0, rel=0.5, gate=1,filt=1000|
		var env, sig, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = HPF.ar(BBandStop.ar( PlayBuf.ar(1,buf,rate,loop:1) < LFSaw.ar([mod, mod*1.3]), [filt,filt*1.3], 12), 40) * 0.5;
	    OffsetOut.ar(out, Limiter.ar(sig * env * amp, 0.95));
	}).add();

Pdef(patName,
Pbind(
	\instrument, \slot2,
	\amp, 3,
	\rel, 0.05,
	\mod, mod,
	\dur, Prand([0.1,0.2,0.3,0.4], inf) * 0.4,
	\buf, Prand(sounds, inf)
));

/*Ndef(\seima).filter(1, {|in| XFade2.ar(in, FreqShift.ar(in, -100), -0.5) });
Ndef(\seima).filter(2, {|in| XFade2.ar(in, Greyhole.ar(in, 0.1, 0.95), -0.5) });*/

output

};

reconstruct

)
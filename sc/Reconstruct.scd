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

	reconstruct

)
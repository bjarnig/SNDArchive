////////////////////////////////////////////////////////////////
//
//                SNDArchive - Reconstruct
//
////////////////////////////////////////////////////////////////

(

var reconstruct = ();

{

    ~srcnstrb = Buffer.alloc(s, 512); s.sync;

    // SynthDefs

	SynthDef(\grain, {
		|out=0,buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0|
		var sig, shape, env, pos;
		shape = Env([0, amp, 0], [dur*0.5, dur*0.5], \sine);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\grainSharp, {
		|out=0,buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, olap=0.05|
		var sig, shape, env, pos;
		shape = Env([0, amp, amp, 0], [olap,dur,olap], \sine);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos);
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

    SynthDef(\grainSharp2, {
		|out=0,buf=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, olap=0.05|
		var sig, shape, env, pos;
		shape = Env([0, amp, amp, 0], [olap,dur,olap], \sine);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(2, buf, rate * BufRateScale.ir(buf), 1, pos);
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

    SynthDef(\trigItem, {
		|buf=0, rate=1, start=0, amp=0.75, dur=0.3, pan=0, bassFreq=50, bassAmp=0.25, bassAtk=0.1, bassRel=0.1, bassFb=0.3|
		var sig, shape, env, pos, onsets, trigger, bleeps, chain;
		shape = Env([0, amp, amp, 0], [dur*0.01, dur*0.89, dur*0.2]);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		chain = FFT(~srcnstrb, sig);
		onsets = Onsets.kr(chain, MouseX.kr(0,1), \complex);
		bleeps = SinOscFB.ar(bassFreq, bassFb, EnvGen.kr(Env.perc(bassAtk, bassRel, bassAmp), onsets));
		bleeps = HPF.ar(bleeps, 20);
		OffsetOut.ar(0, ((sig * EnvGen.kr(Env.perc(0.01, dur, 1.5)))).dup * env);
		OffsetOut.ar(0, HPF.ar(bleeps * 0.8,40).dup * env);
	}).add;

	SynthDef(\trigItem2, {
		|buf=0, rate=1, start=0, amp=0.75, dur=0.3, pan=0, bassFreq=50, bassAmp=0.25, bassAtk=0.1, bassRel=0.1, bassFb=0.3|
		var sig, shape, env, pos, onsets, trigger, bleeps, chain;
		shape = Env([0, amp, amp, 0], [dur*0.01, dur*0.89, dur*0.2]);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(2, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		chain = FFT(~srcnstrb, sig);
		onsets = Onsets.kr(chain, MouseX.kr(0,1), \complex);
		bleeps = SinOscFB.ar(bassFreq, bassFb, EnvGen.kr(Env.perc(bassAtk, bassRel, bassAmp), onsets));
		bleeps = HPF.ar(bleeps, 20);
		OffsetOut.ar(0, ((sig * EnvGen.kr(Env.perc(0.01, dur, 1.5)))).dup * env);
		OffsetOut.ar(0, HPF.ar(bleeps * 0.8,40).dup * env);
	}).add;

	SynthDef(\sines, {
		|out=0,freq=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, olap=0.05|
		var sig, shape, env, pos;
		shape = Env.perc(releaseTime:0.3);
		env = EnvGen.ar(shape, doneAction: 2);
		sig = SinOsc.ar(freq,0,0.2);
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\sines2, {
		|out=0,freq=0, rate=1, start=0, amp=0.5, dur=0.3, pan=0, olap=0.05|
		var sig, shape, env, pos;
		shape = Env.perc(releaseTime:0.3);
		env = EnvGen.ar(shape, doneAction: 2);
		sig = SinOsc.ar(freq,0,0.2);
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\dist, {
		|out=0, buf=0, rate=1, start=0, atk=0.05, amp=0.75, dur=0.3, pan=0|
		var sig, shape, env, pos, lpf=150, hpf=4000, gaina=1000, gainb=200;
		shape = Env([0, amp, amp, 0], [atk, dur*0.9, dur*0.1]);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		sig = HPF.ar(SoftClipAmp8.ar(sig, pregain:gaina) * EnvGen.ar(Env([0.2,0.1,0.0], [6,4,10])),
		Lag.ar(LFNoise0.ar(1).range(hpf, hpf*2))) +
		LPF.ar(SoftClipAmp8.ar(sig, pregain:gainb) * EnvGen.ar(Env([0.2,0.1,0.0], [5,5,15])),
		Lag.ar(LFNoise0.ar(2).range(lpf*0.25, lpf)));
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\dist2, {
		|out=0, buf=0, rate=1, start=0, atk=0.05, amp=0.75, dur=0.3, pan=0|
		var sig, shape, env, pos, lpf=150, hpf=4000, gaina=1000, gainb=200;
		shape = Env([0, amp, amp, 0], [atk, dur*0.9, dur*0.1]);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(2, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		sig = HPF.ar(SoftClipAmp8.ar(sig, pregain:gaina) * EnvGen.ar(Env([0.2,0.1,0.0], [6,4,10])),
		Lag.ar(LFNoise0.ar(1).range(hpf, hpf*2))) +
		LPF.ar(SoftClipAmp8.ar(sig, pregain:gainb) * EnvGen.ar(Env([0.2,0.1,0.0], [5,5,15])),
		Lag.ar(LFNoise0.ar(2).range(lpf*0.25, lpf)));
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\distsaw, {
		|out=0, buf=0, amp=1, mod=9, rate=1, pos=0, pan=1.0, atk=0.01, dec=0.5, sus=1.0, rel=0.5, gate=1,filt=1000|
		var env, sig, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = HPF.ar(BBandStop.ar( PlayBuf.ar(1,buf,rate,loop:1) < LFSaw.ar([mod, mod*1.3]), [filt,filt*1.3], 12), 40) * 0.5;
		OffsetOut.ar(out, Limiter.ar(sig * env * amp, 0.95));
	}).add;

	SynthDef(\distsaw2, {
		|out=0, buf=0, amp=1, mod=9, rate=1, pos=0, pan=1.0, atk=0.01, dec=0.5, sus=1.0, rel=0.5, gate=1,filt=1000|
		var env, sig, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = HPF.ar(BBandStop.ar( PlayBuf.ar(2,buf,rate,loop:1) < LFSaw.ar([mod, mod*1.3]), [filt,filt*1.3], 12), 40) * 0.5;
		OffsetOut.ar(out, Limiter.ar(sig * env * amp, 0.95));
	}).add;

	SynthDef(\distfold, {
		|out=0, buf=0, amp=1, mod=9, rate=1, pos=0, pan=1.0, atk=0.01, dec=0.5, sus=1.0, rel=0.5, gate=1,filt=1000|
		var env, sig, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = HPF.ar(BBandStop.ar(PlayBuf.ar(1, buf, rate, 1, offset, 1).fold2([mod,mod*1.5]), filt, 8), 40) * 2;
		OffsetOut.ar(out, sig * env * amp);
	}).add;

	SynthDef(\distfold2, {
		|out=0, buf=0, amp=1, mod=9, rate=1, pos=0, pan=1.0, atk=0.01, dec=0.5, sus=1.0, rel=0.5, gate=1,filt=1000|
		var env, sig, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = HPF.ar(BBandStop.ar(PlayBuf.ar(2, buf, rate, 1, offset, 1).fold2([mod,mod*1.5]), filt, 8), 40) * 2;
		OffsetOut.ar(out, sig * env * amp);
	}).add;

	SynthDef(\am, {
		|out=0, buf=0, rate=1, start=0, amp=0.95, dur=0.3, pan=0, am=50|
		var sig, shape, env, pos;
		shape = Env([0, amp, amp, 0], [dur*0.01, dur*0.89, dur*0.1]);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(1, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		sig = sig.amclip(SinOsc.ar(am));
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\am, {
		|out=0, buf=0, rate=1, start=0, amp=0.95, dur=0.3, pan=0, am=50|
		var sig, shape, env, pos;
		shape = Env([0, amp, amp, 0], [dur*0.01, dur*0.89, dur*0.1]);
		env = EnvGen.ar(shape, doneAction: 2);
		pos = start * BufSamples.ir(buf);
		sig = PlayBuf.ar(2, buf, rate * BufRateScale.ir(buf), 1, pos, 0);
		sig = sig.amclip(SinOsc.ar(am));
		OffsetOut.ar(out, Pan2.ar(sig * env, pan));
	}).add;

	SynthDef(\pink, {
		|out=0, buf=0, amp=0.2, note=60, rate=1.0 atk=0.01, dec=0.1, sus=1, rel=0.8, rq=0.8, pos=0.125, gate=1.0|
		var sig, env, pan, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = PinkNoise.ar * Amplitude.ar(Mix(PlayBuf.ar(1, buf, rate, 1, offset), 0.01, pos*0.5, 1.3));
		sig = sig + Mix(PlayBuf.ar(1, buf, rate, 1, offset).tanh);
		sig = BBandStop.ar(sig, LFNoise2.ar(2).range(500,2000), rq);
		pan = Pan2.ar(sig * env);
		OffsetOut.ar(out, pan);
	}).add;

	SynthDef(\pink, {
		|out=0, buf=0, amp=0.2, note=60, rate=1.0 atk=0.01, dec=0.1, sus=1, rel=0.8, rq=0.8, pos=0.125, gate=1.0|
		var sig, env, pan, offset;
		env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, amp, doneAction:2);
		rate = BufRateScale.ir(buf) * rate;
		offset = BufFrames.kr(buf) * pos;
		sig = PinkNoise.ar * Amplitude.ar(Mix(PlayBuf.ar(1, buf, rate, 1, offset), 0.01, pos*0.5, 1.3));
		sig = sig + Mix(PlayBuf.ar(2, buf, rate, 1, offset).tanh);
		sig = BBandStop.ar(sig, LFNoise2.ar(2).range(500,2000), rq);
		pan = Pan2.ar(sig * env);
		OffsetOut.ar(out, pan);
	}).add;

}.fork;


// Utils

reconstruct.format = {|ev,sounds|
	if(sounds.isString, {
		ev.archive.items[sounds]
	}, {
		sounds
	})
};

reconstruct.durBufStart = {|ev,sounds,overlap|
	Pfunc {|event|
		var part = sounds.wrapAt(event.index);
		var buf = ev.archive.buffers[part.path];
		var normlized = part.start / buf.duration;
		var dur = (part.end - part.start) * overlap;
		[dur, buf, normlized[0]]
	}
};

reconstruct.instrument = {|ev,instrument|
	Pfunc{|e| if(e.buf.numChannels == 2, { instrument.asString ++ "2" }, { instrument }) }
};

// Reconstructions

reconstruct.test = {|ev,sounds|
	Routine({
		inf.do{
		sounds.do{|part, i|
			var buf = ev.archive.buffers[part.path];
			var normlized = part.start / buf.duration;
			var dur = part.end - part.start;
			Synth(\grainSharp, [\dur, dur, \buf, buf, \start, normlized[0]]);
			dur.wait;
		}}
	});
};

reconstruct.normal = {|ev,sounds,name,amp=1,rate=1,overlap=1,
instrument=\grainSharp,repeats=inf|
	var index = 0; sounds = ev.format(sounds);
	Ndef(name)[0] =
	Pbind(
		\instrument, instrument,
		\amp, amp, \rate, rate,
		\index, Pseq((0..(sounds.size-1)),repeats),
		[\dur, \buf, \start], reconstruct.durBufStart(sounds,overlap),
		\instrument, reconstruct.instrument(instrument)
	)
};

reconstruct.lwhite = {|ev,sounds,name,amp=1,rate=1,overlap=1,
instrument=\dist,repeats=inf|
	var index = 0; sounds = ev.format(sounds);
	Ndef(name)[0] =
	Pbind(
		\amp, amp,\rate, rate,
		\index, Pwhite(0, sounds.size-1,repeats),
		[\dur, \buf, \start], reconstruct.durBufStart(sounds,overlap)


	)
};

reconstruct.lbrown = {|ev,sounds,name,amp=1,rate=1,overlap=1,
instrument=\dist,repeats=inf|
	var index = 0; sounds = ev.format(sounds);
	Ndef(name)[0] =
	Pbind(
		\instrument, instrument,
		\amp, amp,\rate, rate,
		\index, Pbrown(0, sounds.size-1, 1,repeats),
		[\dur, \buf, \start], reconstruct.durBufStart(sounds,overlap)
	)
};

reconstruct.lbeta = {|ev,sounds,name,amp=1,rate=1,overlap=1,
instrument=\dist,repeats=inf|
	var index = 0; sounds = ev.format(sounds);
	Ndef(name)[0] =
	Pbind(
		\instrument, instrument,
		\amp, amp,\rate, 1,
		\index, Pbeta(0, sounds.size-1, length: sounds.size * repeats),
		[\dur, \buf, \start], reconstruct.durBufStart(sounds,overlap)
	)
};

reconstruct.tgrain = {|ev,sounds,name,amp=1,rate=1,trig=50,grSizeFrom=0.001,grSizeTo=0.1|
	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {
		arg pan=0;
		var trigger = Impulse.kr(trig);
		var buf = Demand.kr(trigger, 0, Dxrand(buffers,inf));
		var grSize = Amplitude.kr(PlayBuf.ar(1, buf, loop:1)).range(grSizeFrom, grSizeTo);
		var pos = Amplitude.kr(PlayBuf.ar(1, buf, loop:1)).range(0, BufDur.kr(buf));
		Splay.ar(TGrains.ar(1, trigger, buf, [0.5,1,2], pos, grSize, pan, amp))
	})
};

reconstruct.dringmod = {|ev,sounds,name,amp=1,rate=1,mod=1,rel=2,instrument=\distsaw|
	sounds = ev.format(sounds);
	Ndef(name)[0] =
	Pbind(\instrument, instrument,
	\index, Pseq((0..(sounds.size-1)),inf), \buf, Pfunc{|en| var part=sounds[en.index]; ev.archive.buffers[part.path]},
	\rel, rel, \amp, amp, \rate, rate, \pos, Pfunc{|en| var part=sounds[en.index];  part.start / en.buf.duration }, \mod, mod,
	\dur, Pfunc{|en| var part=sounds[en.index];  part.end - part.start })
};

reconstruct.tartini = {|ev,sounds,name,amp=1,rate=1|
	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {
		var in, freq, hasFreq, vol, snd, trig=0.5;
		var trigger = Impulse.kr(trig);
		var buf = Demand.kr(trigger, 0, Dxrand(buffers,inf));
		snd = PlayBuf.ar(1, buf,rate);
		vol = RunningSum.ar(snd).linlin(-1,1, 0.0, amp);
		# freq, hasFreq = Tartini.kr(snd);
		Saw.ar(freq*[1,2]) * vol;
	})
};

reconstruct.wform = {arg ev,sounds,name,amp=1,rate=1,dfrom=0.01,dto=1.0,dur=60;
	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {
		var in, freq, hasFreq, vol, snd, trig=1;
		var trigger = Impulse.kr(trig);
		var buf = Demand.kr(trigger, 0, Dxrand(buffers,inf));
		var levels = Dseq([-1, 1], inf);
		var durs = Dseq([ Drand([dur,dur*2,dur*3],20), Dbrown(1,20,1,10) ], inf);
		var pitch = Tartini.kr(PlayBuf.ar(1, buf,rate)).range(dfrom, dto);
		DemandEnvGen.ar(levels, SampleDur.ir * durs * pitch[1] ! 2, 1, 0, 1) * 0.15
	})
};

reconstruct.disc = {|ev,sounds,name,amp=1,rate=1,freq=18|
	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {
		var trig=1;
		var trigger = Impulse.kr(trig);
		var buf = Demand.kr(trigger, 0, Dxrand(buffers,inf));
		HPF.ar(BBandStop.ar( PlayBuf.ar(1,buf).fold2(SinOsc.ar( [freq,freq+1])), 300, 8), 60) * 6
	})
};

reconstruct.ringing = {|ev,sounds,name,amp=1,rate=1,freq=80|
	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {
		var trig=1;
		var trigger = Impulse.kr(trig);
		var buf = Demand.kr(trigger, 0, Dxrand(buffers,inf));
		var snd = BBandStop.ar( PlayBuf.ar(1,buf,loop:1).amclip(Saw.ar( freq )), [freq*6,freq*8], 3) * LFDorm.ar();
		var ampf = Amplitude.ar(snd).range(0.5,8);
		(snd * 0.75) + LPF.ar( CombC.ar( snd, 0.1, 0.1, ampf), 150) * 3
	})
};

reconstruct.aggregate = {|ev,sounds,name,amp=1,rate=1,freq=80|
	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {var freq = 80;
	var snd = BBandStop.ar( PlayBuf.ar(1,buffers.choose,loop:1).amclip(Saw.ar( freq )), [freq*6,freq*8], 3) * LFDorm.ar();
	var ampf = Amplitude.ar(snd).range(0.5,8);
	(snd * 0.75) + LPF.ar( CombC.ar( snd, 0.1, 0.1, ampf), 150)})
};

reconstruct.highsaw = {|ev,sounds,name|

	var buffers;
	sounds = ev.format(sounds);
	buffers = sounds.collect{|snd| ev.archive.buffers[snd.path] };

	Ndef(name, {|harms=170, modFreq=9, modFreq2=1, modFreq3=3.1|
	var mod = SinOsc.ar(LFNoise2.kr(modFreq2).range(modFreq * 5, 0.5), 0, LFNoise1.kr(modFreq/10).range(5, 20));
	var freq = Pitch.kr(PlayBuf.ar(1,buffers.choose));
	var sig = Splay.ar(Saw.ar(Array.series(5, freq, freq/24) + mod));
	sig = BPeakEQ.ar(BBandStop.ar(sig, harms * 10, 2.5), LFNoise1.kr(modFreq, 3500, 8000), 1, -10) * 2;
		Splay.ar(sig * LFNoise1.ar(modFreq3).range(0.3,1.1) * Amplitude.kr(PlayBuf.ar(1,buffers.choose), 0.1,0.1,2)) ;
	}).play;

};
	
	reconstruct
	
)
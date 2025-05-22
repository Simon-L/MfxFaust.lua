// declare options "[midi:on]";
import("stdfaust.lib");

// gate = button("gate");

// samplesf = so.sound(soundfile("/tmp/truc.wav", 1), 0);
// sample = samplesf.play(1.0, os.impulse);

// process = os.osc(hslider("osc1",440,10,10000,1)) * en.ar(10e-3, 130e-3, gate);
process = os.osc(880) * en.ar(10e-3, 130e-3, ba.beat(120)) <: _,_;
// process = sample;
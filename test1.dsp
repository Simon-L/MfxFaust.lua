declare options "[midi:on]";
import("stdfaust.lib");

// gate = button("gate");

// process = os.osc(hslider("osc1",440,10,10000,1)) * en.ar(10e-3, 130e-3, gate);
process = os.osc(220) * en.ar(10e-3, 130e-3, ba.beat(120));
// process = 0.1;
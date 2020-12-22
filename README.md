# Speech-Synthesizer
A speech synthesizer emulating the SPO256 speech synthesizer chip from the 1980s.

The code applies DSP algorithms and a **picoblaze embedded processor** to output voice messages counting from 0 - 21 and ending the cycle with the statement "I hate COVID 19) before restarting.

Used **Signal Tap** for debugging and ModelSim to run testbenches.
Download the sof file, load it onto your DE1SoC, connect headphones and press E.

I included only the crucial files where I made significant changes.

- simple_ipod_solution.v: This is the top level module where everything is instantiated
- picoblaze_template.v: This contains the code that interfaces with the picoblaze
- Avaregin_Algorithm.v: Averaging code
- mem_control_fsm.v: code that outputs wave signals for reading memory
- audio_control_fsm.v code that sends out addresses to mem

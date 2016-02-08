rem runs viado simulation batch files and displays resulting waveform in GUI
mkdir simulate
call xelab_batch.bat
cd ..
call simulate_xsim_no_gui.bat
cd ..

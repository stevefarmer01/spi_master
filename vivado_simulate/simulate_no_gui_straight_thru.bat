rem runs viado simulation batch files and displays resulting waveform in GUI
rmdir /s /q simulate
mkdir simulate
call xelab_batch_straight_thru.bat
cd ..
call simulate_xsim_no_gui.bat
cd ..

rem runs viado simulation batch files and displays resulting waveform in GUI
rmdir /s /q simulate
mkdir simulate
call gdrb_testbench_xelab_batch.bat
cd ..
call gdrb_testbench_simulate_xsim_no_gui.bat
cd ..

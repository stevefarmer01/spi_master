rem runs viado simulation batch files and displays resulting waveform in GUI
rmdir /s /q simulate
mkdir simulate
call xelab_batch_board_select.bat
cd ..
call simulate_xsim_gui_board_select.bat
cd ..

import cmd
import os
import shutil

class cmd_simple(cmd.Cmd):

  intro = 'Welcome to the test enviroment for the GDRB Begalbone SPI.\nType help or ? to list commands.\n'
  prompt = '(GDRB Begalbone SPI) '
# to include test 4 need to add ability to modify vhdl generics during simulation
#  test_list_dict = {'0' : 'input_test_read_writes.txt', '1' : 'input_test_interupt_sensor.txt', '2' : 'input_test_interupt_fault.txt', '3' : 'input_test_interupt_misc.txt', '4' : 'input_test_vanilla_read_writes.txt'}
  test_list_dict = {
                    '0' : ['input_test_read_writes.txt', r'simulate_gui.bat', r'simulate_no_gui.bat', 'input_test.txt', 'output_test.txt'], 
                    '1' : ['input_test_interupt_sensor.txt', r'simulate_gui.bat', r'simulate_no_gui.bat', 'input_test.txt', 'output_test.txt'], 
                    '2' : ['input_test_interupt_fault.txt', r'simulate_gui.bat', r'simulate_no_gui.bat', 'input_test.txt', 'output_test.txt'], 
                    '3' : ['input_test_interupt_misc.txt', r'simulate_gui.bat', r'simulate_no_gui.bat', 'input_test.txt', 'output_test.txt'], 
                    '4' : ['begalbone_master_spi_input_test.txt', r'gdrb_testbench_simulate_gui.bat', r'gdrb_testbench_simulate_no_gui.bat', 'gdhb_master_spi_input_test.txt', 'begalbone_master_spi_output_test.txt']
                    }
#  input_test_file = "input_test.txt"
#  output_test_file = "output_test.txt"
  test_results_dir = "test_results"
  if not os.path.exists(test_results_dir): os.makedirs(test_results_dir)
  run_all_tests_results_file = "run_all_tests_results.txt"

  def copy_to_input_test_txt(self, test_number):
    if os.path.isfile(self.test_list_dict[test_number][4]):       # Remove will cause run time error if file doesn't exist
      os.remove(self.test_list_dict[test_number][4])              # Remove previous results so that if test fails to compile/run an erroneous pass will not be detected
    print 'Running test ' + test_number + ' .........'
    print 'Copying file \'' + self.test_list_dict[test_number][0] + '\' to \'' + self.test_list_dict[test_number][3] + '\''
    shutil.copyfile(self.test_list_dict[test_number][0], self.test_list_dict[test_number][3])
    return;

  def check_results(self, test_number, file=None):
    error_in_result_file = False
    if os.path.isfile(self.test_list_dict[test_number][4]):       # Search will cause run time error if file doesn't exist
      searchfile = open(self.test_list_dict[test_number][4], "r")
      for line in searchfile:
        if "ERROR" in line: 
          error_in_result_file = True
  #          print "    " + line
  #          if not file == None:
  #            file.write(line) # python will convert \n to os.linesep # Print ERROR lines into run_all_tests_results.txt (bit confusing at the moment)
    if not file == None:   # When running running all test results in a file 'run_all_tests_results.txt' in directory 'test_results'
      if not os.path.isfile(self.test_list_dict[test_number][4]):
        file.write('DID NOT RUN.......')
      elif error_in_result_file:
        file.write('FAILED............')
      else:
        file.write('PASSED............')
      file.write(test_number + '_results_' + self.test_list_dict[test_number][0] + '\n')
    else:                   # When not running all tests print final result to screen
      if not os.path.isfile(self.test_list_dict[test_number][4]):
        test_status = 'DID NOT RUN.......'
      elif error_in_result_file:
        test_status = 'FAILED............'
      else:
        test_status = 'PASSED............'
      print '\n' + test_status + test_number + '_results_' + self.test_list_dict[test_number][0] + '\n'
    if os.path.isfile(self.test_list_dict[test_number][4]):       # Close will cause run time error if file doesn't exist
      searchfile.close()

  def copy_results(self, test_number):
    print 'Copying test result to directory - /' + self.test_results_dir
    if os.path.isfile(self.test_list_dict[test_number][4]):       # Copy will cause run time error if file doesn't exist
      shutil.copyfile(self.test_list_dict[test_number][4], "test_results/" + test_number + '_results_' + self.test_list_dict[test_number][0])


  def do_run_test_gui(self, test_number):
    '''do_run_test_gui[test number] -- Simulates test [test number] and opens waveform in GUI'''
    if not self.test_list_dict.has_key(test_number):
      print 'Need a valid test number - no test run\n'
      return
    print 'Running Test - ' + test_number + '\n'
    self.copy_to_input_test_txt(test_number)
    os.system(self.test_list_dict[test_number][1])
    self.check_results(test_number)
    self.copy_results(test_number)

  def do_run_test_no_gui(self, test_number, file=None):
    '''do_run_test_no_gui[test number] -- Simulates test [test number] no GUI'''
    if not self.test_list_dict.has_key(test_number):
      print 'Need a valid test number - no test run\n'
      return
    print 'Running Test - ' + test_number + '\n'
    self.copy_to_input_test_txt(test_number)
    os.system(self.test_list_dict[test_number][2])
    self.check_results(test_number, file)
    self.copy_results(test_number)

# This doesn't work with test_input.txt vectors that expect any processing or in/out pins
#  def do_run_test_no_gui_straight_thru(self, test_number, file=None):
#    '''do_run_test_no_gui[test number] -- Simulates test [test number] no GUI'''
#    if not self.test_list_dict.has_key(test_number):
#      print 'Need a valid test number - no test run\n'
#      return
#    print 'Running Test - ' + test_number + '\n'
#    self.copy_to_input_test_txt(test_number)
#    os.system(r'simulate_no_gui_straight_thru.bat')
#    self.check_results(test_number, file)
#    self.copy_results(test_number)

  def do_run_all_tests(self, line):
    f = open(self.test_results_dir + '/' + self.run_all_tests_results_file,'w')
    for k,v in self.test_list_dict.items():
      self.do_run_test_no_gui(k, f)
    f.close()
    f = open(self.test_results_dir + '/' + self.run_all_tests_results_file,'r')
    print "Results for all tests......"
    print f.read()

  def do_list_tests(self, test_number):
    for k,v in self.test_list_dict.items():
      print k," - ",v


  def do_exit(self, line):
    return True

if __name__ == '__main__':
  cmd_simple().cmdloop()

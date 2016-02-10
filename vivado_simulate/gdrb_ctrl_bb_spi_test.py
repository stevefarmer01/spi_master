import cmd
import os
import shutil

class cmd_simple(cmd.Cmd):

  intro = 'Welcome to the test enviroment for the GDRB Begalbone SPI.\nType help or ? to list commands.\n'
  prompt = '(GDRB Begalbone SPI) '
  test_list_dict = {'0' : 'input_test_read_writes.txt', '1' : 'input_test_interupt_sensor.txt', '2' : 'input_test_interupt_fault.txt', '3' : 'input_test_interupt_misc.txt'}
  input_test_file = "input_test.txt"
  output_test_file = "output_test.txt"
  test_results_dir = "test_results"
  if not os.path.exists(test_results_dir): os.makedirs(test_results_dir)
  run_all_tests_results_file = "run_all_tests_results.txt"

  def copy_to_input_test_txt(self, test_number):
    if os.path.isfile(self.output_test_file):       # Remove will cause run time error if file doesn't exist
      os.remove(self.output_test_file)              # Remove previous results so that if test fails to compile/run an erroneous pass will not be detected
    print 'Running test ' + test_number + ' .........'
    print 'Copying file \'' + self.test_list_dict[test_number] + '\' to \'' + self.input_test_file + '\''
    shutil.copyfile(self.test_list_dict[test_number], self.input_test_file)
    return;

  def check_results(self, test_number, file=None):
    error_in_result_file = False
    if os.path.isfile(self.output_test_file):       # Search will cause run time error if file doesn't exist
      searchfile = open(self.output_test_file, "r")
      for line in searchfile:
        if "ERROR" in line: 
          error_in_result_file = True
  #          print "    " + line
  #          if not file == None:
  #            file.write(line) # python will convert \n to os.linesep # Print ERROR lines into run_all_tests_results.txt (bit confusing at the moment)
    if not file == None:
      if not os.path.isfile(self.output_test_file):
        file.write('DID NOT RUN.......')
      elif error_in_result_file:
        file.write('FAILED............')
      else:
        file.write('PASSED............')
      file.write(test_number + '_results_' + self.test_list_dict[test_number] + '\n')
    else:
      if not os.path.isfile(self.output_test_file):
        test_status = 'DID NOT RUN.......'
      elif error_in_result_file:
        test_status = 'FAILED............'
      else:
        test_status = 'PASSED............'
      print '\n' + test_status + test_number + '_results_' + self.test_list_dict[test_number] + '\n'
    if os.path.isfile(self.output_test_file):       # Close will cause run time error if file doesn't exist
      searchfile.close()

  def copy_results(self, test_number):
    print 'Copying test result to directory - /' + self.test_results_dir
    if os.path.isfile(self.output_test_file):       # Copy will cause run time error if file doesn't exist
      shutil.copyfile(self.output_test_file, "test_results/" + test_number + '_results_' + self.test_list_dict[test_number])


  def do_run_test_gui(self, test_number):
    '''do_run_test_gui[test number] -- Simulates test [test number] and opens waveform in GUI'''
    if not self.test_list_dict.has_key(test_number):
      print 'Need a valid test number - no test run\n'
      return
    print 'Running Test - ' + test_number + '\n'
    self.copy_to_input_test_txt(test_number)
    os.system(r'simulate_gui.bat')
    self.check_results(test_number)
    self.copy_results(test_number)

  def do_run_test_no_gui(self, test_number, file=None):
    '''do_run_test_no_gui[test number] -- Simulates test [test number] no GUI'''
    if not self.test_list_dict.has_key(test_number):
      print 'Need a valid test number - no test run\n'
      return
    print 'Running Test - ' + test_number + '\n'
    self.copy_to_input_test_txt(test_number)
    os.system(r'simulate_no_gui.bat')
    self.check_results(test_number, file)
    self.copy_results(test_number)

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

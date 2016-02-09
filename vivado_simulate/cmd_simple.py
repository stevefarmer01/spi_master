import cmd
import os

class cmd_simple(cmd.Cmd):

  test_list_dict = {000 : 'input_test_read_writes.txt', 001 : 'input_test_interupt_sensor.txt', 002 : 'input_test_interupt_fault.txt', 003 : 'input_test_interupt_misc.txt'}

  def copy_to_input_test_txt(self):
    print 'copying'
    return;

  def do_run_test_gui(self, test_number):
    '''do_run_test_gui[test number] -- Simulates test [test number] and opens waveform in GUI'''
    if test_number:
      print 'Testing - ' + test_number + '\n'
    else:
      print 'Need a test number - no test run\n'
    #os.system(r'simulate_gui.bat')
    self.copy_to_input_test_txt()


  def do_run_test_no_gui(self, test_number):
    '''do_run_test_no_gui[test number] -- Simulates test [test number] no GUI'''
    if test_number:
      print 'Testing - ' + test_number + '\n'
    else:
      print 'Need a test number - no test run\n'
    #os.system(r'simulate_no_gui.bat')

  def do_list_tests(self, test_number):
    print self.test_list_dict
    for k,v in self.test_list_dict.items():
      print k," - ",v


  def do_EOF(self, line):
    return True

if __name__ == '__main__':
  cmd_simple().cmdloop()

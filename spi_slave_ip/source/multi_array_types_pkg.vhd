library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package multi_array_types_pkg is

    type mem_array_t is
        array (natural range <>, natural range <>)  of std_logic;

    function get_data (input_array : mem_array_t;
                        address : natural) return std_logic_vector;

    procedure set_data (--signal clk : in std_logic;
                        signal mem_array : inout mem_array_t;
                        address : in natural;
                        data : in std_logic_vector
                        );

    procedure set_all_data (--signal clk : in std_logic;
                        signal mem_array_in : in mem_array_t;
                        signal mem_array_out : out mem_array_t
                        );

end multi_array_types_pkg;


package body multi_array_types_pkg is

    function get_data (input_array : mem_array_t;
                        address : natural) return std_logic_vector is
        variable data : std_logic_vector(input_array'RANGE(2));
    begin
        for i in input_array'RANGE(2) loop
            data(i) := input_array(address,i);
        end loop;
        return data;
    end get_data;
    
    procedure set_data (--signal clk : in std_logic;
                        signal mem_array : inout mem_array_t;
                        address : in natural;
                        data : in std_logic_vector
                        ) is
    begin
        for x in mem_array'RANGE(1) loop
            for i in mem_array'RANGE(2) loop
                if x = address then 
                    mem_array(address,i) <= data(i);
                else
                    mem_array(x,i) <= mem_array(x,i);
                end if;
            end loop;
        end loop;
    end set_data;
    
    procedure set_all_data (--signal clk : in std_logic;
                        signal mem_array_in : in mem_array_t;
                        signal mem_array_out : out mem_array_t
                        ) is
    begin
        for x in mem_array_in'RANGE(1) loop
            for i in mem_array_in'RANGE(2) loop
                    mem_array_out(x,i) <= mem_array_in(x,i);
            end loop;
        end loop;
    end set_all_data;
    
end;
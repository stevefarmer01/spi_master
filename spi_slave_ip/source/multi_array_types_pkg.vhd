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
                        signal mem_array : out mem_array_t;
                        address : in natural;
                        data : in std_logic_vector
                        );

    procedure set_all_data (--signal clk : in std_logic;
--                        signal mem_array_in : in mem_array_t;
                        constant mem_array_in : in mem_array_t;
                        signal mem_array_out : out mem_array_t
                        );

    function get_data_bit (input_array : mem_array_t;
                        address : natural;
                        bit_address : natural) return std_logic;

    function get_data_bits (input_array : mem_array_t;
                        address : natural;
                        bit_address_hi_range : natural;
                        bit_address_lo_range : natural) return std_logic_vector;

--Below does not annoyingly work used above instead
--    function get_data_bits (input_array : mem_array_t;
--                        address : natural;
--                        bit_address_range : natural range <>) return std_logic_vector;

    procedure set_data_v (--signal clk : in std_logic;
                        variable mem_array : inout mem_array_t;
                        address : in natural;
                        data : in std_logic_vector
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
                        signal mem_array : out mem_array_t;
                        address : in natural;
                        data : in std_logic_vector
                        ) is
    begin
            for i in mem_array'RANGE(2) loop
                    mem_array(address,i) <= data(i);
            end loop;
    end set_data;
    
    procedure set_all_data (--signal clk : in std_logic;
--                        signal mem_array_in : in mem_array_t;
                        constant mem_array_in : in mem_array_t;
                        signal mem_array_out : out mem_array_t
                        ) is
    begin
        for x in mem_array_in'RANGE(1) loop
            for i in mem_array_in'RANGE(2) loop
                    mem_array_out(x,i) <= mem_array_in(x,i);
            end loop;
        end loop;
    end set_all_data;
    
    function get_data_bit (input_array : mem_array_t;
                        address : natural;
                        bit_address : natural) return std_logic is
        variable data : std_logic;
    begin
        data := input_array(address,bit_address);
        return data;
    end get_data_bit;
    
    function get_data_bits (input_array : mem_array_t;
                        address : natural;
                        bit_address_hi_range : natural;
                        bit_address_lo_range : natural) return std_logic_vector is
--                        bit_address_range : std_logic_vector) return std_logic_vector is
        variable data : std_logic_vector(bit_address_hi_range downto bit_address_lo_range);
    begin
--        for i in bit_address_range'RANGE loop
        for i in bit_address_hi_range downto bit_address_lo_range loop
            data(i) := input_array(address,i);
        end loop;
        return data;
    end get_data_bits;
    
--Below does not annoyingly work used above instead
--    function get_data_bits (input_array : mem_array_t;
--                        address : natural;
--                        bit_address_range : natural range <>) return std_logic_vector is
--        variable data : std_logic_vector(bit_address_range);
--    begin
--        for i in bit_address_range loop
--            data(i) := input_array(address,i);
--        end loop;
--        return data;
--    end get_data_bits;
--
--Called using....
--BluePattern_s <= get_data_bits(reg_map_array_to_pins_s, gdrb_dp_mux_pattern_control_addr_c, 7 downto 6);

    procedure set_data_v (--signal clk : in std_logic;
                        variable mem_array : inout mem_array_t;
                        address : in natural;
                        data : in std_logic_vector
                        ) is
    begin
            for i in mem_array'RANGE(2) loop
                    mem_array(address,i) := data(i);
            end loop;
    end set_data_v;
    


end;
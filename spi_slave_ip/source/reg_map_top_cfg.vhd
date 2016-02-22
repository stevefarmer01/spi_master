use work.all;
configuration cfg_gdrb_ctrl_reg_map of gdrb_ctrl_reg_map_top is
    for Behavioral
--        for application_inst : gdrb_ctrl_reg_map
        for all: gdrb_ctrl_reg_map
--            use entity work.gdrb_ctrl_reg_map(Behavioral);
            use entity work.generic_reg_map(Behavioral);
        end for;
    end for;
end cfg_gdrb_ctrl_reg_map;
--generic_spi_reg_map_top
--generic_reg_map
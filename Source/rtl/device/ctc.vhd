-- Z80 CTC
-- Copyright 2020 Alvin Albrecht
--
-- This file is part of the ZX Spectrum Next Project
-- <https://gitlab.com/SpectrumNext/ZX_Spectrum_Next_FPGA/tree/master/cores>
--
-- The ZX Spectrum Next FPGA source code is free software: you can 
-- redistribute it and/or modify it under the terms of the GNU General 
-- Public License as published by the Free Software Foundation, either 
-- version 3 of the License, or (at your option) any later version.
--
-- The ZX Spectrum Next FPGA source code is distributed in the hope 
-- that it will be useful, but WITHOUT ANY WARRANTY; without even the 
-- implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
-- PURPOSE.  See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with the ZX Spectrum Next FPGA source code.  If not, see 
-- <https://www.gnu.org/licenses/>.

-- Reference:
-- http://www.zilog.com/docs/z80/ps0181.pdf
--
-- The im2 vector and im2 interrupt are not implemented here.  Instead
-- relevant signals are exported so that im2 mode can be optionally
-- implemented by the instantiating module.
--
-- Clarifications per CTC channel:
--
-- 1. Hard reset requires a control word and then a time constant to be
--    written even if bit 2 = 0 in the control word.
--
-- 2. Soft reset with bit 2 = 0 causes the entire control register to
--    be modified.  Soft reset with bit 2 = 1 does not change the control
--    register contents.  In both cases a time constant must follow
--    to resume operation.
--
-- 3. Changing the trigger edge selection in bit 4 while the channel
--    is in operation counts as a clock edge.  A pending timer trigger
--    will be fired and, in counter mode, an edge will be received.
--
-- 4. ZC/TO is asserted for one clock cycle and not for the entire
--    duration that the count is at zero.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ctc is
   generic (
      constant NUM_CTC       : positive := 4;
      constant NUM_CTC_LOG2  : positive := 2
   );
   port (
     
      i_CLK                  : in std_logic;
      i_reset                : in std_logic;
      
      i_port_ctc_wr          : in std_logic;                                  -- one of the ctc channel ports is being written
      i_port_ctc_sel         : in std_logic_vector(NUM_CTC_LOG2-1 downto 0);  -- which one, numbered

      i_int_en_wr            : in std_logic;                              -- separately write interrupt enable bits, must not overlap port_ctc_wr
      i_int_en               : in std_logic_vector(NUM_CTC-1 downto 0);   -- interrupt enable bits
      
      i_cpu_d                : in std_logic_vector(7 downto 0);
      o_cpu_d                : out std_logic_vector(7 downto 0);          -- data read from ctc port
      
      i_clk_trg              : in std_logic_vector(NUM_CTC-1 downto 0);   -- clock/trigger signals for each ctc channel, must be synchronized
      
      o_im2_vector_wr        : out std_logic;                             -- im2 vector is being written (not handled in this module)
      
      o_zc_to                : out std_logic_vector(NUM_CTC-1 downto 0);  -- zc/to for each ctc channel, asserted for one i_CLK cycle
      o_int_en               : out std_logic_vector(NUM_CTC-1 downto 0)   -- interrupt enable for each channel
   
   );
end entity;

architecture rtl of ctc is

   type dout_t is array (NUM_CTC-1 downto 0) of std_logic_vector(7 downto 0);
   signal dout    : dout_t;
   
   signal sel     : std_logic_vector(NUM_CTC-1 downto 0);
   
   signal iowr    : std_logic_vector(NUM_CTC-1 downto 0);
   signal iowr_tc : std_logic_vector(NUM_CTC-1 downto 0);

begin

   -- CTC Channels
   
   gen_ctc:
   for I in 0 to NUM_CTC-1 generate
   
      ctc: entity work.ctc_chan
      port map (
            i_CLK       => i_CLK,
            i_reset     => i_reset,

            i_iowr      => iowr(I),
            o_iowr_tc   => iowr_tc(I),

            i_int_en_wr => i_int_en_wr,
            i_int_en    => i_int_en(I),

            i_cpu_d     => i_cpu_d,
            o_cpu_d     => dout(I),

            i_clk_trg   => i_clk_trg(I),

            o_zc_to     => o_zc_to(I),
            o_int_en    => o_int_en(I)
      );

   end generate;
   
   -- Select CTC
   
   process (i_port_ctc_sel)
   begin
      for I in 0 to NUM_CTC-1 loop
         if I = unsigned(i_port_ctc_sel) then
            sel(I) <= '1';
         else
            sel(I) <= '0';
         end if;
      end loop;
   end process;   

   -- Route Signals
   
   process (i_port_ctc_wr, sel)
   begin
      for I in 0 to NUM_CTC-1 loop
         iowr(I) <= i_port_ctc_wr and sel(I);
      end loop;
   end process;

   -- Output

   process (iowr_tc, sel, i_port_ctc_wr, i_cpu_d)
      variable tmp_iowr_tc : std_logic;
   begin
      tmp_iowr_tc := '0';
      
      for I in 0 to NUM_CTC-1 loop
         tmp_iowr_tc := tmp_iowr_tc or (iowr_tc(I) and sel(I));
      end loop;
      
      o_im2_vector_wr <= i_port_ctc_wr and (not i_cpu_d(0)) and (not tmp_iowr_tc);
   end process;

   process (dout, sel)
      variable tmp_dout : std_logic_vector(7 downto 0);
   begin
      tmp_dout := (others => '0');
      
      for I in 0 to NUM_CTC-1 loop
         tmp_dout := tmp_dout or ((dout(I)(7) and sel(I)) & (dout(I)(6) and sel(I)) & (dout(I)(5) and sel(I)) & (dout(I)(4) and sel(I)) & 
                                  (dout(I)(3) and sel(I)) & (dout(I)(2) and sel(I)) & (dout(I)(1) and sel(I)) & (dout(I)(0) and sel(I)) );
      end loop;
      
      o_cpu_d <= tmp_dout;
   end process;

end architecture;

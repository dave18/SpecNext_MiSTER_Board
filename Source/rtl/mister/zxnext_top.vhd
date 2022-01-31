
-- ZX Spectrum Next Issue 2 FPGA Top Level
-- Copyright 2020 Alvin Albrecht and Fabio Belavenuto
--
-- TBBLUE Issue 2 Top - Fabio Belavenuto
-- ZXNext Refactor - Alvin Albrecht
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity zxnext_top is
   generic (
      g_machine_id      : unsigned(7 downto 0)  := X"DA";   -- MiSTer
      g_version         : unsigned(7 downto 0)  := X"31";   -- 3.01
      g_sub_version     : unsigned(7 downto 0)  := X"0A"    -- .10
   );
   port (
		-- Clocks
		CLK_28            : in  std_logic;
		CLK_14            : in  std_logic;
		CLK_7             : in  std_logic;
		CLK_HDMI             : in  std_logic;
		
		HW_RESET          : in  std_logic;
		SW_RESET          : in  std_logic;

		CPU_SPEED         : out std_logic_vector(1 downto 0);
--		CPU_SPEED_SW      : in  std_logic := '0';
		CPU_WAIT          : in  std_logic := '0';

--		RAM_A_ADDR        : out std_logic_vector(20 downto 0);   -- 2MB memory space
--		RAM_A_REQ         : out std_logic;                       -- '1' indicates memory request on next rising edge
--		RAM_A_RD_n        : out std_logic;                       -- '0' for read, '1' for write
--		RAM_A_DI          : in  std_logic_vector(7 downto 0);     -- data read from memory
--		RAM_A_DO          : out std_logic_vector(7 downto 0);    -- data written to memory
--
--		RAM_B_ADDR        : out std_logic_vector(20 downto 0);   -- 2MB memory space
--		RAM_B_REQ         : out std_logic;                       -- toggle indicates memory request
--		RAM_B_DI          : in  std_logic_vector(7 downto 0);     -- data read from memory
		
		
		-- SRAM (AS7C34096)
      ram_addr_o        : out   std_logic_vector(18 downto 0)  := (others => '0');
      ram_data_io       : inout std_logic_vector(15 downto 0)  := (others => 'Z');
      ram_oe_n_o        : out   std_logic                      := '1';
      ram_we_n_o        : out   std_logic                      := '1';
      ram_ce_n_o        : out   std_logic_vector( 3 downto 0)  := (others => '1');
		
		

		-- PS2
		ps2_key           : in  std_logic_vector(10 downto 0);
		ps2_mouse         : in  std_logic_vector(24 downto 0);
		ps2_mouse_ext     : in  std_logic_vector(7 downto 0);		

		-- SD Card
		sd_cs0_n_o        : out std_logic;
		sd_cs1_n_o        : out std_logic;
		sd_sclk_o         : out std_logic;
		sd_mosi_o         : out std_logic;
		sd_miso_i         : in  std_logic := '1';

		
		 -- Joystick -- active high  X Z Y START A C B U D L R
      joyp1_i           : in    std_logic;
      joyp2_i           : in    std_logic;
      joyp3_i           : in    std_logic;
      joyp4_i           : in    std_logic;
      joyp6_i           : in    std_logic;
      joyp7_o           : out   std_logic                      := '1';
      joyp9_i           : in    std_logic;
      joysel_o          : out   std_logic                      := '0';
		
		joy_left_type_o   : out std_logic_vector(2 downto 0);
		joy_right_type_o  : out std_logic_vector(2 downto 0);
		
		-- Audio
		audio_L           : out std_logic_vector(11 downto 0);
		audio_R           : out std_logic_vector(11 downto 0);
		
		audioext_l_o      : out   std_logic                      := '0';
      audioext_r_o      : out   std_logic                      := '0';
      audioint_o        : out   std_logic                      := '0';

		-- K7
		ear_port_i_m      : in    std_logic := '1';
		ear_port_i        : in    std_logic;
		mic_port_o        : out   std_logic                      := '0';
		tape_ready			: in    std_logic;
		
      -- Buttons
      btn_divmmc_n_i    : in    std_logic;
      btn_multiface_n_i : in    std_logic;
      btn_reset_n_i     : in    std_logic;
		
		-- VGA
		RGB               : out std_logic_vector(8 downto 0);    -- RGB333
		RGB_VS_n          : out std_logic;                       -- vsync
		RGB_HS_n          : out std_logic;                       -- hsync
		RGB_VB_n          : out std_logic;                       -- vblank
		RGB_HB_n          : out std_logic;                       -- hblank
		RGB_NTSC          : out std_logic;
		
		 -- VGA
      rgb_r_o           : out   std_logic_vector( 2 downto 0)  := (others => '0');
      rgb_g_o           : out   std_logic_vector( 2 downto 0)  := (others => '0');
      rgb_b_o           : out   std_logic_vector( 2 downto 0)  := (others => '0');
      hsync_o           : out   std_logic                      := '1';
      vsync_o           : out   std_logic                      := '1';

		-- I2C (RTC)
		i2c_scl_o         : out std_logic;
		i2c_sda_o         : out std_logic;
		i2c_sda_i         : in  std_logic := '1';

		uart_rx_i         : in  std_logic;
		uart_tx_o         : out std_logic
	);
end entity;

architecture rtl of zxnext_top is



	signal btn_divmmc_n_i_q       : std_logic;
   signal btn_multiface_n_i_q    : std_logic;
   signal btn_reset_n_i_q        : std_logic;

   -- resets
   
   signal zxn_video_mode         : std_logic_vector(2 downto 0);
   signal actual_video_mode      : std_logic_vector(2 downto 0)   := "000";

   signal reset_counter          : std_logic_vector(9 downto 0);
   signal reset                  : std_logic;
   
   signal zxn_reset_hard         : std_logic;
   signal zxn_reset_soft         : std_logic;
   
   -- clocks
   
   signal CLK_i0                 : std_logic;
   signal CLK_CPU                : std_logic;
   signal q0                     : std_logic;
   signal q0_enable              : std_logic;
   signal q1                     : std_logic;
   signal q1_enable              : std_logic;
   
   signal clk_28_div             : std_logic_vector(17 downto 0);
   
   signal CLK_28_PSG_EN          : std_logic;
	signal CLK_28_DEBOUNCE_EN     : std_logic;
   signal CLK_28_JOY_EN          : std_logic;
   signal CLK_28_MEMBRANE_EN     : std_logic;
   
   signal zxn_clock_contend      : std_logic;
   signal zxn_clock_lsb          : std_logic;
   signal zxn_cpu_speed          : std_logic_vector(1 downto 0);
   signal zxn_cpu_speed2         : std_logic_vector(1 downto 0);
	
	
	-- sram interface
   
   signal sram_port_b_req        : std_logic;
   signal zxn_ram_b_req          : std_logic;
   signal sram_addr              : std_logic_vector(20 downto 0);
   signal sram_cs_n              : std_logic_vector(3 downto 0);
   signal sram_data_H            : std_logic;
   signal sram_rd                : std_logic;
   
   signal sram_cs_n_active       : std_logic_vector(3 downto 0)   := (others => '1');
   signal sram_oe_n_active       : std_logic                      := '0';
   signal sram_addr_active       : std_logic_vector(18 downto 0)  := (others => '0');
   signal sram_data_active       : std_logic_vector(15 downto 0)  := (others => '0');
   signal sram_port_a_active     : std_logic                      := '0';
   signal sram_port_b_active     : std_logic                      := '0';
   signal sram_data_H_active     : std_logic                      := '0';
   
   signal sram_data_in           : std_logic_vector(15 downto 0);
   signal sram_port_a_read       : std_logic;
   signal sram_port_b_read       : std_logic;
   signal sram_data_H_read       : std_logic;
   signal sram_data_in_byte      : std_logic_vector(7 downto 0);
   
   signal sram_port_a_dat        : std_logic_vector(7 downto 0);
   signal sram_port_b_dat        : std_logic_vector(7 downto 0);
   signal sram_port_a_do         : std_logic_vector(7 downto 0);
   signal sram_port_b_do         : std_logic_vector(7 downto 0);
   
   signal sram_we_line           : std_logic_vector(3 downto 0)   := (others => '0');

   -- serial communication
   
   signal zxn_i2c_scl            : std_logic;

   -- audio
	
	signal ear_port_i_q           : std_logic;
	signal ear_port_i_q2          : std_logic;
   signal audioint               : std_logic;
   signal mic_port               : std_logic;
   signal audioext_m             : std_logic;
   signal audioext_l             : std_logic;
   signal audioext_r             : std_logic;
   
   signal zxn_hdmi_audio         : std_logic;
   signal zxn_speaker_en         : std_logic;
   signal zxn_speaker_beep       : std_logic;
   signal zxn_tape_mic           : std_logic;

   signal zxn_audio_ear          : std_logic;
   signal zxn_audio_mic          : std_logic;
   
   signal zxn_audio_L_pre        : std_logic_vector(12 downto 0);
   signal zxn_audio_R_pre        : std_logic_vector(12 downto 0);

   signal zxn_audio_L            : std_logic_vector(11 downto 0);
   signal zxn_audio_R            : std_logic_vector(11 downto 0);

   signal zxn_audio_M_s          : std_logic_vector(13 downto 0);
   signal zxn_audio_M            : std_logic_vector(14 downto 0);
	
	 -- video : vga
   
   signal ha_value               : integer range 0 to 2047;
   
   signal rgb_15                 : std_logic_vector(8 downto 0);
   signal rgb_31                 : std_logic_vector(8 downto 0);
   
   signal hsync_out              : std_logic;
   signal vsync_out              : std_logic;
   signal blank_out              : std_logic;
	signal hblank_out             : std_logic;
	signal vblank_out             : std_logic;
   
   signal zxn_rgb                : std_logic_vector(8 downto 0);
   signal zxn_rgb_cs_n           : std_logic;
   signal zxn_rgb_hs_n           : std_logic;
   signal zxn_rgb_vs_n           : std_logic;
   signal zxn_video_scanlines    : std_logic_vector(1 downto 0) := (others => '0');
   signal zxn_rgb_vb_n           : std_logic;
   signal zxn_rgb_hb_n           : std_logic;
   signal zxn_machine_timing     : std_logic_vector(2 downto 0);
   signal zxn_video_scandouble_en   : std_logic;
	
   
   -- buttons, joystick, mouse, keyboard
   
   
   signal btn_reset_db_n            : std_logic;
   signal btn_reset_noise_n         : std_logic;
   signal btn_m1_multiface_db_n     : std_logic;
   signal btn_m1_multiface_noise_n  : std_logic;
   signal btn_drive_divmmc_db_n     : std_logic;
   signal btn_drive_divmmc_noise_n  : std_logic;

   signal zxn_buttons            : std_logic_vector(1 downto 0);
	
	signal rgb_hs_n_dly           : std_logic_vector(1 downto 0);
	signal CLK_28_HSYNC_EN        : std_logic;

   signal joyp1_i_q              : std_logic;
   signal joyp2_i_q              : std_logic;
   signal joyp3_i_q              : std_logic;
   signal joyp4_i_q              : std_logic;
   signal joyp6_i_q              : std_logic;
   signal joyp9_i_q              : std_logic;
	
	signal zxn_joy_left           : std_logic_vector(10 downto 0);
   signal zxn_joy_right          : std_logic_vector(10 downto 0);
	
--	signal zxn_joy_left2          : std_logic_vector(10 downto 0);
--   signal zxn_joy_right2         : std_logic_vector(10 downto 0);
	
   signal zxn_joy_io_mode_en     : std_logic;
   signal zxn_joy_io_mode_pin_7  : std_logic;
   
   signal zxn_joy_left_type      : std_logic_vector(2 downto 0);
   signal zxn_joy_right_type     : std_logic_vector(2 downto 0);

   signal zxn_mouse_control      : std_logic_vector(2 downto 0);
   signal zxn_mouse_x            : std_logic_vector(7 downto 0);
   signal zxn_mouse_y            : std_logic_vector(7 downto 0);
   signal zxn_mouse_wheel        : std_logic_vector(7 downto 0);
   signal zxn_mouse_button       : std_logic_vector(2 downto 0);
   signal zxn_mouse_stb          : std_logic;
   
   signal ps2_kbd_col            : std_logic_vector(6 downto 0);
   signal ps2_kbd_fn             : std_logic_vector(11 downto 1);

   signal zxn_keymap_addr        : std_logic_vector(8 downto 0);
   signal zxn_keymap_dat         : std_logic_vector(7 downto 0);
   signal zxn_keymap_we          : std_logic;
   signal zxn_joymap_we          : std_logic;
   
   signal zxn_key_row            : std_logic_vector(7 downto 0);
	signal key_row_filtered       : std_logic_vector(7 downto 0);
   signal zxn_key_col            : std_logic_vector(4 downto 0);
	signal membrane_function_keys : std_logic_vector(10 downto 1);
   
   signal zxn_cancel_extended_entries  : std_logic;
   signal zxn_extended_keys      : std_logic_vector(15 downto 0);
   
   signal membrane_index         : std_logic_vector(2 downto 0);
   signal membrane_stick_col     : std_logic_vector(6 downto 0);
	
	signal zxn_function_keys      : std_logic_vector(10 downto 1);
	
	
	signal zxn_ram_a_addr         : std_logic_vector(20 downto 0);
   signal zxn_ram_a_req          : std_logic;
   signal zxn_ram_a_rd           : std_logic;
   signal zxn_ram_a_di           : std_logic_vector(7 downto 0);
   signal zxn_ram_a_do           : std_logic_vector(7 downto 0);
   
   signal zxn_ram_b_addr         : std_logic_vector(20 downto 0);
   signal zxn_ram_b_req_t        : std_logic;
   signal zxn_ram_b_di           : std_logic_vector(7 downto 0);
	
   
	function mouse_scale(off : std_logic_vector(7 downto 0); scale : std_logic_vector(1 downto 0)) return std_logic_vector is
	begin
		-- avoid -1 value if negative off is less than scale
		case(scale) is
			when "00" =>
				return off;
				
			when "01" =>
				if off <= X"FE" then
					return off(7) & off(7 downto 1);
				end if;
			
			when "10" =>
				if off <= X"FC" then
					return off(7) & off(7) & off(7 downto 2);
				end if;

			when "11" =>
				if off <= X"F8" then
					return off(7) & off(7) & off(7) & off(7 downto 3);
				end if;
		end case;

		return (others => '0');
	end function;

begin

   ------------------------------------------------------------
   -- SYNCHRONIZE ASYNCHRONOUS INPUTS
   ------------------------------------------------------------
	
	
   -- Joystick

   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
			joyp1_i_q <= joyp1_i;
			joyp2_i_q <= joyp2_i;
			joyp3_i_q <= joyp3_i;
			joyp4_i_q <= joyp4_i;
			joyp6_i_q <= joyp6_i;
			joyp9_i_q <= joyp9_i;
      end if;
   end process;	
	
	joy_left_type_o <= zxn_joy_left_type;			--additional code
	joy_right_type_o <= zxn_joy_right_type;		--additional code
	
	
   -- K7
	
   ear_sync : entity work.synchronize
   port map
   (
      i_CLK    => CLK_28,
      i_signal => ear_port_i,
      o_signal => ear_port_i_q
   );
	
	
   -- Buttons
   
   btn_div_sync : entity work.synchronize
   port map
   (
      i_CLK    => CLK_28,
      i_signal => btn_divmmc_n_i,
      o_signal => btn_divmmc_n_i_q
   );

   btn_mf_sync : entity work.synchronize
   port map
   (
      i_CLK    => CLK_28,
      i_signal => btn_multiface_n_i,
      o_signal => btn_multiface_n_i_q
   );
   
   btn_reset_sync : entity work.synchronize
   port map
   (
      i_CLK    => CLK_28,
      i_signal => btn_reset_n_i,
      o_signal => btn_reset_n_i_q
   );
	
   ------------------------------------------------------------
   -- RESETS --------------------------------------------------
   ------------------------------------------------------------

   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         if zxn_video_mode /= actual_video_mode or (zxn_reset_soft or zxn_reset_hard or SW_RESET) = '1' then
            actual_video_mode <= zxn_video_mode;
            reset_counter <= (others => '1');
				reset <= '1';
         elsif reset_counter /= "0000000000" then
            reset_counter <= reset_counter - 1;
			else
				reset <= '0';
         end if;
      end if;
   end process;
   
   ------------------------------------------------------------
   -- CLOCKS --------------------------------------------------
   ------------------------------------------------------------
   
	CPU_SPEED <= zxn_cpu_speed2;

   -- cpu clock selection
	process (CLK_28)
	begin
		if rising_edge(CLK_28) then
			case(zxn_cpu_speed2) is
				when "00"   =>
					if clk_28_div(1 downto 0) = "00" then
						if zxn_clock_lsb = '1' and zxn_clock_contend = '0' then
							CLK_i0 <= '0';
						elsif zxn_clock_lsb = '0' then
							CLK_i0 <= '1';
						end if;
					end if;

				when "01"   =>
					CLK_i0 <= clk_28_div(1);

				when others =>
					CLK_i0 <= clk_28_div(0);
			end case;
			
			if clk_28_div(1 downto 0) = "11" then
				zxn_cpu_speed2 <= zxn_cpu_speed;
			end if;
		end if;
	end process;
	
   process(q1, CLK_i0)
   begin
       if (q1 = '1') then
           q0_enable <= '0';
       elsif falling_edge(CLK_i0) then
           q0_enable <= '1';
       end if;
   end process;
   
   process(q0, CLK_28)
   begin
       if (q0 = '1') then
           q1_enable <= '0';
       elsif falling_edge(CLK_28) then
           q1_enable <= '1';
       end if;
   end process;

   q0 <= not (zxn_cpu_speed(1) and zxn_cpu_speed(0)) and q0_enable when rising_edge(CLK_i0);
   q1 <=     (zxn_cpu_speed(1) and zxn_cpu_speed(0)) and q1_enable when rising_edge(CLK_28);

   CLK_CPU <= CLK_i0 when q0 = '1' else CLK_28 when q1 = '1' else '1';

   -- Clock Enables
   clk_28_div <= clk_28_div + 1 when rising_edge(CLK_28);
   
   CLK_28_PSG_EN <= '1' when clk_28_div(3 downto 0) = "1110" else '0';                   -- AY clock enable @ 1.75MHz
	CLK_28_DEBOUNCE_EN <= '1' when clk_28_div(17 downto 0) = ("11" & X"FFFF") else '0';   -- 9.36ms period for debounce
   CLK_28_JOY_EN <= '1' when clk_28_div(6 downto 0) = ("111" & X"F") else '0';           -- stick step every 4.57us (pulse width = 9.14us for each side)
   CLK_28_MEMBRANE_EN <= '1' when clk_28_div(8 downto 7) = "11" and CLK_28_JOY_EN = '1' else '0';  -- complete scan every 2.5 scanlines (0.018ms per row)
	
   ------------------------------------------------------------
   -- SRAM INTERFACE ------------------------------------------
   ------------------------------------------------------------
   
   -- https://www.alliancememory.com/wp-content/uploads/pdf/sram/fa/as7c34096a_v2.1.pdf
   -- https://www.idt.com/document/dst/71v424-data-sheet
   
   -- SRAM cycles are executed within every 28MHz cycle and are
   -- granted to one of three simultaneous requesters, with the
   -- cpu granted highest priority and layer 2 granted second
   -- priority.

   -- To ensure that a 28MHz cpu speed would be possible, the 
   -- initial design allocates the entire 28MHz period to the 
   -- sram memory cycle with the result of reads stored at the 
   -- end of the period on the next rising edge.  This has
   -- the consequence that cpu instruction fetches and DMA
   -- 2-cycle reads must have one wait state inserted at 28MHz 
   -- speed.

   -- For memory write timing, the 5 x 28MHz hdmi clock is used
   -- to time the write pulse to ensure the write address is
   -- stable before the write pulse is asserted and to ensure
   -- the write cycle is completed before the end of the 28MHz period.
   
   -- Hard and soft resets span many 28MHz cycles so the currently
   -- running sram cycle is allowed to complete before the sram
   -- is held in a neutral state during the reset.  This ensures
   -- spurious writes don't contaminate the sram during soft reset.
   
   -- In the notation below, port A is r/w and is the highest
   -- priority assigned to the cpu.  Port B is read-only and
   -- is second priority assigned to layer 2.  Layer 2 requests
   -- can be delayed by one cycle so they are fine soaking up
   -- spare sram bandwidth at second priority.

   -- PORT A (R/W) (cpu/dma):
   --
   -- zxn_ram_a_addr   : std_logic_vector(20 downto 0)
   -- zxn_ram_a_req    : '1' on rising edge indicates memory request
   -- zxn_ram_a_rd     : '1' for read, '0' for write
   -- zxn_ram_a_do     : std_logic_vector(7 downto 0) data to write to memory
   -- zxn_ram_a_di     : std_logic_vector(7 downto 0) data read from memory
   
   -- PORT B (R) (layer 2):
   --
   -- zxn_ram_b_addr   : std_logic_vector(20 downto 0)
   -- zxn_ram_b_req_t  : toggles to indicate new request
   -- zxn_ram_b_di     : std_logic_vector(7 downto 0) data read from memory
   
   -- PORT C (R/W) (dma, soaks up spare bandwidth)
   
   -- SRAM I/O PINS:
   --
   -- ram_addr_o       : std_logic_vector(18 downto 0)
   -- ram_data_io      : std_logic_vector(15 downto 0)
   -- ram_oe_n_o
   -- ram_we_n_o
   -- ram_ce_n_o       : std_logic_vector(3 downto 0)
   
   -- Determine active port and sram signals for next memory cycle
   
   zxn_ram_b_req <= (zxn_ram_b_req_t xor sram_port_b_req) and not zxn_ram_a_req;   -- 0 = Port A (or nothing), 1 = Port B
   sram_addr <= (zxn_ram_a_addr(20) & zxn_ram_a_addr(0) & zxn_ram_a_addr(19 downto 1)) when zxn_ram_b_req = '0' else (zxn_ram_b_addr(20) & zxn_ram_b_addr(0) & zxn_ram_b_addr(19 downto 1));
   
   -- Track port B request which operates on a toggled signal
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         if zxn_ram_b_req = '1' then
            sram_port_b_req <= zxn_ram_b_req_t;
         end if;
      end if;
   end process;

   -- Select active sram chip
   
   process (zxn_ram_a_req, zxn_ram_b_req, sram_addr)
   begin
      if zxn_ram_a_req = '1' or zxn_ram_b_req = '1' then
         case sram_addr(20 downto 19) is
            when "00"   =>  sram_cs_n <= "1110";
            when "01"   =>  sram_cs_n <= "1101";
            when "10"   =>  sram_cs_n <= "1011";
            when others =>  sram_cs_n <= "0111";
         end case;
      else
         sram_cs_n <= (others => '1');
      end if;
   end process;
   
   sram_data_H <= sram_addr(19);
   sram_rd <= (zxn_ram_a_rd or not zxn_ram_a_req) when zxn_ram_b_req = '0' else '1';
   
   -- Memory cycle
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         if reset = '1' then
         
            sram_cs_n_active <= (others => '1');
            sram_oe_n_active <= '0';
            sram_addr_active <= (others => '0');
            sram_data_active <= (others => '0');
            
            sram_port_a_active <= '0';
            sram_port_b_active <= '0';
            
            sram_data_H_active <= '0';

         else

            sram_cs_n_active <= sram_cs_n;
            sram_oe_n_active <= not sram_rd;
            sram_addr_active <= sram_addr(18 downto 0);
            sram_data_active <= zxn_ram_a_do & zxn_ram_a_do;
            
            sram_port_a_active <= zxn_ram_a_req;
            sram_port_b_active <= zxn_ram_b_req;
            
            sram_data_H_active <= sram_data_H;

         end if;
      end if;
   end process;
   
   -- Data in (R)
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         sram_data_in <= ram_data_io;
      end if;
   end process;
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         sram_port_a_read <= sram_port_a_active and not sram_oe_n_active;
         sram_port_b_read <= sram_port_b_active and not sram_oe_n_active;
         sram_data_H_read <= sram_data_H_active;
      end if;
   end process;
   
   sram_data_in_byte <= sram_data_in(7 downto 0) when sram_data_H_read = '0' else sram_data_in(15 downto 8);
   
   --
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         if sram_port_a_read = '1' then
            sram_port_a_dat <= sram_data_in_byte;
         end if;
      end if;
   end process;
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         if sram_port_b_read = '1' then
            sram_port_b_dat <= sram_data_in_byte;
         end if;
      end if;
   end process;
   
   sram_port_a_do <= sram_data_in_byte when sram_port_a_read = '1' else sram_port_a_dat;
   sram_port_b_do <= sram_data_in_byte when sram_port_b_read = '1' else sram_port_b_dat;
   
   -- Data out (W)
   -- 28MHz cycle is partitioned into five periods some of which will carry we signal
   
   process (CLK_HDMI)
   begin
      if rising_edge(CLK_HDMI) then
         if sram_oe_n_active = '1' and sram_we_line = "0000" then
            sram_we_line <= "1111";
            ram_we_n_o <= '0';
         else
            sram_we_line <= sram_we_line(2 downto 0) & '0';
            if sram_we_line(3 downto 1) = "111" then
               ram_we_n_o <= '0';
            else
               ram_we_n_o <= '1';
            end if;
         end if;
      end if;
   end process;
   
   -- Connect I/O signals
   
   -- make sure xst is pushing registers into io blocks
   
   ram_addr_o <= sram_addr_active;
   ram_data_io <= sram_data_active when sram_oe_n_active = '1' else (others => 'Z');
   ram_oe_n_o <= sram_oe_n_active;
   ram_ce_n_o <= sram_cs_n_active;
   
   zxn_ram_a_di <= sram_port_a_do;
   zxn_ram_b_di <= sram_port_b_do;	
   
   ------------------------------------------------------------
   -- BUTTONS, JOYSTICKS, MOUSE, KEYBOARD ---------------------
   ------------------------------------------------------------

	
	-- reset button
   
   db_0_noise : entity work.debounce
      generic map
   (
      INITIAL_STATE  => '1',
      COUNTER_SIZE   => 4      -- 16 * CLK_28 = ~571ns
   )
   port map
   (
      clk_i          => CLK_28,
      clk_en_i       => '1',
      button_i       => btn_reset_n_i_q,
      button_o       => btn_reset_noise_n
   );
   
   db_0_bounce : entity work.debounce
   generic map
   (
      INITIAL_STATE  => '1',
      COUNTER_SIZE   => 3      -- 8 * CLK_28_DEBOUNCE_EN period = ~ 74.8ms
   )
   port map
   (
      clk_i          => CLK_28,
      clk_en_i       => CLK_28_DEBOUNCE_EN,
      button_i       => btn_reset_noise_n,
      button_o       => btn_reset_db_n
   );

   -- multiface nmi button (nmi)
   
   db_1_noise : entity work.debounce
      generic map
   (
      INITIAL_STATE  => '1',
      COUNTER_SIZE   => 4      -- 16 * CLK_28 = ~571ns
   )
   port map
   (
      clk_i          => CLK_28,
      clk_en_i       => '1',
      button_i       => btn_multiface_n_i_q,
      button_o       => btn_m1_multiface_noise_n
   ); 

   db_1_bounce : entity work.debounce
   generic map
   (
      INITIAL_STATE  => '1',
      COUNTER_SIZE   => 3      -- 8 * CLK_28_DEBOUNCE_EN period = ~ 74.8ms
   )
   port map
   (
      clk_i          => CLK_28,
      clk_en_i       => CLK_28_DEBOUNCE_EN,
      button_i       => btn_m1_multiface_noise_n,
      button_o       => btn_m1_multiface_db_n
   );
   
   -- divmmc nmi button (drive)

   db_2_noise : entity work.debounce
      generic map
   (
      INITIAL_STATE  => '1',
      COUNTER_SIZE   => 4      -- 16 * CLK_28 = ~571ns
   )
   port map
   (
      clk_i          => CLK_28,
      clk_en_i       => '1',
      button_i       => btn_divmmc_n_i_q,
      button_o       => btn_drive_divmmc_noise_n
   );

   db_2_bounce : entity work.debounce
   generic map
   (
      INITIAL_STATE  => '1',
      COUNTER_SIZE   => 3      -- 8 * CLK_28_DEBOUNCE_EN period = ~ 74.8ms
   )
   port map
   (
      clk_i          => CLK_28,
      clk_en_i       => CLK_28_DEBOUNCE_EN,
      button_i       => btn_drive_divmmc_noise_n,
      button_o       => btn_drive_divmmc_db_n
   );
   
   zxn_buttons <= not (btn_drive_divmmc_db_n & btn_m1_multiface_db_n);
	
	
   -- joysticks
   -- md controller reads all joystick types
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         rgb_hs_n_dly <= rgb_hs_n_dly(0) & zxn_rgb_hs_n;
      end if;
   end process;
   
   CLK_28_HSYNC_EN <= rgb_hs_n_dly(1) and not rgb_hs_n_dly(0);	
	
	joystick_mod : entity work.md6_joystick_connector_x2
   port map
   (
      i_reset        => reset,
      
      i_CLK_28       => CLK_28,
      i_CLK_EN       => CLK_28_HSYNC_EN,  -- approximately 15kHz enable
      
      i_joy_1_n      => joyp1_i_q,
      i_joy_2_n      => joyp2_i_q,
      i_joy_3_n      => joyp3_i_q,
      i_joy_4_n      => joyp4_i_q,
      i_joy_6_n      => joyp6_i_q,
      i_joy_9_n      => joyp9_i_q,
      
      i_io_mode_en      => zxn_joy_io_mode_en,
      i_io_mode_pin_7   => zxn_joy_io_mode_pin_7,

      o_joy_7        => joyp7_o,          -- md protocol
      o_joy_select   => joysel_o,         -- joystick selection mux (0 = left, 1 = right)

      o_joy_left     => zxn_joy_left,     -- active high  X Z Y START A C B U D L R
      o_joy_right    => zxn_joy_right     -- active high  X Z Y START A C B U D L R
   );
	
	
	
   -- ps2 mouse
	
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then

			zxn_mouse_stb <= ps2_mouse(24);
			if (zxn_mouse_stb xor ps2_mouse(24)) = '1' then
				zxn_mouse_x    <= zxn_mouse_x + mouse_scale(ps2_mouse(15 downto 8), zxn_mouse_control(1 downto 0));
				zxn_mouse_y    <= zxn_mouse_y + mouse_scale(ps2_mouse(23 downto 16), zxn_mouse_control(1 downto 0));
				zxn_mouse_wheel<= zxn_mouse_wheel + ps2_mouse_ext;
			end if;

			if zxn_mouse_control(2) = '0' then
				zxn_mouse_button <= ps2_mouse(2 downto 0);
			else
				zxn_mouse_button <= (ps2_mouse(2) & ps2_mouse(0) & ps2_mouse(1));
			end if;

      end if;
   end process;

   -- ps2 keyboard

   ps2_kbd_mod : entity work.ps2_keyb
   port map
   (
      i_CLK             => CLK_28,
      i_reset           => reset,

		ps2_key           => ps2_key,

      -- membrane interaction
      i_membrane_row    => membrane_index,
      o_membrane_col    => ps2_kbd_col,

      -- programmable keymap
      i_keymap_addr     => zxn_keymap_addr,
      i_keymap_data     => zxn_keymap_dat,
      i_keymap_we       => zxn_keymap_we,

      fn                => ps2_kbd_fn   -- F11:F1
   );

   -- membrane keyboard
   
   membrane_mod : entity work.membrane
   port map
   (
      i_CLK             => CLK_28,
      i_CLK_EN          => CLK_28_MEMBRANE_EN,
      
      i_reset           => reset,
      
      i_rows            => zxn_key_row,
      o_cols            => zxn_key_col,
      
      o_membrane_ridx   => membrane_index,
      i_membrane_cols   => ps2_kbd_col, --and membrane_stick_col,
      
      i_cancel_extended_entries => zxn_cancel_extended_entries,
      o_extended_keys => zxn_extended_keys
   );
   
   -- membrane joystick
   
--   membrane_stick_mod : entity work.membrane_stick
--   port map
--   (
--      i_CLK             => CLK_28,
--      i_CLK_EN          => CLK_28_MEMBRANE_EN,
--
--      i_reset           => reset,
--
--      i_joy_en_n        => zxn_joy_io_mode_en,
--
--      i_joy_left        => joy_left,
--      i_joy_left_type   => zxn_joy_left_type,
--
--      i_joy_right       => joy_right,
--      i_joy_right_type  => zxn_joy_right_type,
--
--      i_membrane_row    => membrane_index,
--      o_membrane_col    => membrane_stick_col,
--
--      i_keymap_addr     => zxn_keymap_addr(4 downto 0),
--      i_keymap_data     => zxn_keymap_dat(5 downto 0),
--      i_keymap_we       => zxn_joymap_we
--   );
	
	
   ------------------------------------------------------------
   -- AUDIO ---------------------------------------------------
   ------------------------------------------------------------

   -- tape save
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         mic_port <= zxn_tape_mic;
      end if;
   end process;
   
   mic_port_o <= mic_port;
   
   -- audio dac

   audio_L_inst : entity work.dac
   generic map
   (
      msbi_g   => 11
   )
   port map
   (
      clk_i    => CLK_28,
      res_i    => reset,
      dac_i    => zxn_audio_L(11 downto 0),
      dac_o    => audioext_l
   );
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         audioext_l_o <= audioext_l;
      end if;
   end process;
   
   audio_R_inst : entity work.dac
   generic map
   (
      msbi_g   => 11
   )
   port map
   (
      clk_i    => CLK_28,
      res_i    => reset,
      dac_i    => zxn_audio_R(11 downto 0),
      dac_o    => audioext_r
   );
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         audioext_r_o <= audioext_r;
      end if;
   end process;

   -- optional internal speaker

   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         audioint <= audioext_m and zxn_speaker_en;
      end if;
   end process;
   
   audioint_o <= audioint;

   -- VBE(on) = 0.55 V
   -- VBE(max) = 0.8 V
   -- 17-bit dac = 21760 offset, signal range = 0:9929
   
   zxn_audio_M_s <= ('0' & zxn_audio_L_pre) + ('0' & zxn_audio_R_pre);
   
   process (CLK_28)
   begin
      if rising_edge(CLK_28) then
         if zxn_speaker_beep = '1' then
            zxn_audio_M <= zxn_audio_ear & (not zxn_audio_ear) & '0' & zxn_audio_mic & "00000000000";
         else
            zxn_audio_M <= (('0' & zxn_audio_M_s(13 downto 7)) + "01010101") & zxn_audio_M_s(6 downto 0);
         end if;
      end if;
   end process;
   
   audio_M : entity work.dac
   generic map
   (
      msbi_g   => 16     -- only using a small range of 16.7% through 24.2%
   )
   port map
   (
      clk_i    => CLK_28,
      res_i    => reset,
      dac_i    => '0' & zxn_audio_M & '0',
      dac_o    => audioext_m
   );	
	
------------------------------------------------------------
   -- VIDEO : VGA ---------------------------------------------
   ------------------------------------------------------------

   -- note: the values below are relative to the CLK period not standard VGA clock period
   
   sc_mod : entity work.scan_convert
   generic map
   (
      -- mark active area of input video
      
      cstart      =>  38*2,  -- composite sync start
      clength     => 352*2,  -- composite sync length
      
      -- output video timing
      
      hB          =>  32*2,   -- h sync
      hC          =>  40*2,   -- h back porch
      hD          => 352*2,   -- visible video (256 + both borders)
      hpad        =>   0*2,   -- create H black border

      vB          =>   2*2,   -- v sync
      vC          =>   5*2,   -- v back porch
      vD          => 284*2,   -- visible video
      vpad        =>   0*2    -- create V black border
   )
   port map
   (
      CLK         => CLK_14,
      CLK_x2      => CLK_28,

      hA          => ha_value,   -- h front porch
      I_VIDEO     => zxn_rgb,
      I_HSYNC     => zxn_rgb_hs_n,
      I_VSYNC     => zxn_rgb_vs_n,
      I_SCANLIN   => zxn_video_scanlines,
      I_BLANK_N   => zxn_rgb_cs_n,

      O_VIDEO_15  => rgb_15,     -- scanlines processed
      O_VIDEO_31  => rgb_31,     -- scanlines processed
      O_HSYNC     => hsync_out,
      O_VSYNC     => vsync_out,
		O_HBLANK     => hblank_out,
		O_VBLANK     => vblank_out,
      O_BLANK     => blank_out      
   );
   
   ha_value <= 48 when zxn_machine_timing(1) = '0' else 64;   -- 48k = 000 or 001, Pentagon = 100
   
   process (CLK_28)
   begin
      if falling_edge(CLK_28) then
      
         if zxn_video_scandouble_en = '0' then
         
            rgb_r_o <= rgb_15(8 downto 6);
            rgb_g_o <= rgb_15(5 downto 3);
            rgb_b_o <= rgb_15(2 downto 0);
            
            -- csync on hsync when the scandoubler is off
            
--            hsync_o <= zxn_rgb_cs_n;
--            vsync_o <= '1';
				hsync_o <= not zxn_rgb_hs_n;
            vsync_o <= not zxn_rgb_vs_n;
				
            
         else
         
            rgb_r_o <= rgb_31(8 downto 6);
            rgb_g_o <= rgb_31(5 downto 3);
            rgb_b_o <= rgb_31(2 downto 0);
            
            hsync_o <= hsync_out;
            vsync_o <= vsync_out;
         
         end if;
--			hblank_o <= hblank_out;
--		   vblank_o <= vblank_out;
      end if;
   end process;
	
	-- function keys via membrane keyboard
   
   -- mf button held turns keys 0-9 into function keys
   -- mf button held for < ~1000ms indicates multiface nmi

   emu_fnkeys_mod : entity work.emu_fnkeys
   generic map
   (
      CLOCK_EN_PERIOD_MS   => 10,   -- debounce period is 9.6ms
      BUTTON_PERIOD_MS     => 1000  -- button held for less than 1s constitutes a short press
   )
   port map
   (
      i_CLK             => CLK_28,
      i_CLK_EN          => CLK_28_DEBOUNCE_EN,
      
      i_reset           => reset,
      
      i_rows            => zxn_key_row,
   --   o_rows_filtered   => key_row_filtered,
      
      i_cols            => ps2_kbd_col (4 downto 0),-- and membrane_col,
   --   o_cols_filtered   => zxn_key_col,
      
      i_button_m1_n     => btn_m1_multiface_db_n,   -- F9 = multiface nmi
      i_button_reset_n  => btn_reset_db_n,          -- F1 = hard reset, F4 = soft reset
      
      o_fnkeys          => membrane_function_keys   -- F10:F1 out
   );

   ------------------------------------------------------------
   -- SERIAL COMMUNICATION ------------------------------------
   ------------------------------------------------------------

   -- i2c
   
   i2c_scl_o <= zxn_i2c_scl;

   ------------------------------------------------------------
   -- TBBLUE / ZXNEXT -----------------------------------------
   ------------------------------------------------------------

   --  F1 = hard reset
   --  F2 = 
   --  F3 = toggle 50Hz / 60Hz display
   --  F4 = soft reset
   --  F5 = 
   --  F6 = 
   --  F7 = 
   --  F8 = change cpu speed
   --  F9 = m1 button (multiface nmi)
   -- F10 = drive button (divmmc nmi)
	
	zxn_function_keys <= (ps2_kbd_fn(10)  or membrane_function_keys(10) or not btn_drive_divmmc_db_n) & (ps2_kbd_fn(9 downto 1) or membrane_function_keys(9 downto 1));

   zxnext : entity work.zxnext
   generic map
   (
      g_machine_id         => g_machine_id,
      g_version            => g_version,
      g_sub_version        => g_sub_version
   )
   port map
   (
      -- CLOCK
      
      i_CLK_28             => CLK_28,
      i_CLK_28_n           => not CLK_28,
      i_CLK_14             => CLK_14,
      i_CLK_7              => CLK_7,
      i_CLK_CPU            => CLK_CPU,
      i_CLK_PSG_EN         => CLK_28_PSG_EN,
      
      o_CPU_SPEED          => zxn_cpu_speed,
      o_CPU_CONTEND        => zxn_clock_contend,
      o_CPU_CLK_LSB        => zxn_clock_lsb,
      i_CPU_WAIT           => CPU_WAIT,
      
      -- RESET

  --    i_RESET              => reset,
  --    i_BOOT               => ps2_kbd_fn(1) or HW_RESET,
  
		i_RESET_HARD         => ps2_kbd_fn(1) or HW_RESET,
		i_RESET_SOFT         => reset,
      
      o_RESET_HARD         => zxn_reset_hard,
      o_RESET_SOFT         => zxn_reset_soft,
      
      -- SPECIAL KEYS

      i_SPKEY_FUNCTION     => zxn_function_keys,--ps2_kbd_fn(10) & ps2_kbd_fn(9) & (ps2_kbd_fn(8) or CPU_SPEED_SW) & "000" & (ps2_kbd_fn(4) or ps2_kbd_fn(1) or HW_RESET) & ps2_kbd_fn(3) & "00",
      i_SPKEY_BUTTONS      => zxn_buttons,--ps2_kbd_fn(10) & ps2_kbd_fn(9),
      
      -- MEMBRANE KEYBOARD
      
      o_KBD_CANCEL         => zxn_cancel_extended_entries,
      o_KBD_ROW            => zxn_key_row,
      i_KBD_COL            => zxn_key_col,
      i_KBD_EXTENDED_KEYS  => zxn_extended_keys,
      
      -- PS/2 KEYBOARD AND KEY JOYSTICK SETUP
      
      o_KEYMAP_ADDR        => zxn_keymap_addr,
      o_KEYMAP_DATA        => zxn_keymap_dat,
      o_KEYMAP_WE          => zxn_keymap_we,
 --     o_JOYMAP_WE          => zxn_joymap_we,
      
      -- JOYSTICK
      
      i_JOY_LEFT           => zxn_joy_left,--joy_left,
      i_JOY_RIGHT          => zxn_joy_right,--joy_right,
      o_JOY_IO_MODE_EN     => zxn_joy_io_mode_en,
      o_JOY_LEFT_TYPE      => zxn_joy_left_type,
      o_JOY_RIGHT_TYPE     => zxn_joy_right_type,
		o_JOY_IO_MODE_PIN_7  => zxn_joy_io_mode_pin_7,
      
      -- MOUSE
      
      i_MOUSE_X            => zxn_mouse_x,
      i_MOUSE_Y            => zxn_mouse_y,
      i_MOUSE_BUTTON       => zxn_mouse_button,
      i_MOUSE_WHEEL        => zxn_mouse_wheel(3 downto 0),
      o_MOUSE_CONTROL      => zxn_mouse_control,
      
      -- I2C
      
      i_I2C_SCL_n          => zxn_i2c_scl,
      i_I2C_SDA_n          => i2c_sda_i,
      o_I2C_SCL_n          => zxn_i2c_scl,
      o_I2C_SDA_n          => i2c_sda_o,
      
      -- SPI

      o_SPI_SS_SD1_n       => sd_cs1_n_o,
      o_SPI_SS_SD0_n       => sd_cs0_n_o,
      o_SPI_SCK            => sd_sclk_o,
      o_SPI_MOSI           => sd_mosi_o,
      i_SPI_SD_MISO        => sd_miso_i,
      i_SPI_FLASH_MISO     => '1',
      
      -- UART
      
      i_UART0_RX           => uart_rx_i,
      o_UART0_TX           => uart_tx_o,
      
      -- VIDEO
      -- synchronized to i_CLK_14
      
		
		o_RGB                => zxn_rgb,
      o_RGB_CS_n           => zxn_rgb_cs_n,
      o_RGB_VS_n           => zxn_rgb_vs_n,
      o_RGB_HS_n           => zxn_rgb_hs_n,
      o_RGB_VB_n           => zxn_rgb_vb_n,
      o_RGB_HB_n           => zxn_rgb_hb_n,
      --o_RGB                => RGB,
      --o_RGB_VS_n           => RGB_VS_n,
      --o_RGB_HS_n           => RGB_HS_n,
      --o_RGB_VB_n           => RGB_VB_n,
      --o_RGB_HB_n           => RGB_HB_n,
      o_VIDEO_MODE         => zxn_video_mode,
		o_VIDEO_50_60        => RGB_NTSC,

     -- o_VIDEO_50_60        => open, --zxn_video_50_60,
	   --o_VIDEO_50_60        => zxn_video_50_60,
      o_VIDEO_SCANLINES    => zxn_video_scanlines,
      --o_VIDEO_SCANDOUBLE   => open, --zxn_video_scandouble_en,
		o_VIDEO_SCANDOUBLE   => zxn_video_scandouble_en,
      
      --o_VIDEO_MODE         => zxn_video_mode,                     -- VGA 0-6, HDMI
      o_MACHINE_TIMING     => zxn_machine_timing,                 -- video timing: 00X = 48k, 010 = 128k, 011 = +3, 100 = pentagon
      
      -- AUDIO
		
		o_AUDIO_SPEAKER_EN   => zxn_speaker_en,
      o_AUDIO_SPEAKER_BEEP => zxn_speaker_beep,
      
      i_AUDIO_EAR          => ear_port_i_q2,
      o_AUDIO_MIC          => zxn_tape_mic,
		
	   o_AUDIO_SPEAKER_EAR  => zxn_audio_ear,
      o_AUDIO_SPEAKER_MIC  => zxn_audio_mic,	
	
      o_AUDIO_L            => zxn_audio_L_pre,
      o_AUDIO_R            => zxn_audio_R_pre,

      -- EXTERNAL SRAM (synchronized to i_CLK_28)
      -- memory transactions complete in one cycle, data read is registered but available asap
      
--		o_RAM_A_ADDR         => RAM_A_ADDR,
--		o_RAM_A_REQ          => RAM_A_REQ,
--		o_RAM_A_RD_n         => RAM_A_RD_n,
--		i_RAM_A_DI           => RAM_A_DI,
--		o_RAM_A_DO           => RAM_A_DO,
--		o_RAM_B_ADDR         => RAM_B_ADDR,
--		o_RAM_B_REQ_T        => RAM_B_REQ,
--		i_RAM_B_DI           => RAM_B_DI,
		
      -- EXTERNAL SRAM (synchronized to i_CLK_28)
      -- memory transactions complete in one cycle, data read is registered but available asap
      
      -- Port A is read/write and highest priority (CPU)
      
      o_RAM_A_ADDR         => zxn_ram_a_addr,
      o_RAM_A_REQ          => zxn_ram_a_req,
      o_RAM_A_RD           => zxn_ram_a_rd,
      i_RAM_A_DI           => zxn_ram_a_di,
      o_RAM_A_DO           => zxn_ram_a_do,
      
      -- Port B is read only (LAYER 2)
      
      o_RAM_B_ADDR         => zxn_ram_b_addr,
      o_RAM_B_REQ_T        => zxn_ram_b_req_t,
      i_RAM_B_DI           => zxn_ram_b_di,		
      
      -- EXPANSION BUS
      
      i_BUS_DI             => (others => '1'),
      i_BUS_WAIT_n         => '1',
      i_BUS_NMI_n          => '1',
      i_BUS_INT_n          => '1',
      i_BUS_BUSREQ_n       => '1',
      i_BUS_ROMCS_n        => '1',
      i_BUS_IORQULA_n      => '1',
      
      -- ESP GPIO

      i_ESP_GPIO_20        => (others => '1'),
      o_ESP_GPIO_0         => open,
      o_ESP_GPIO_0_EN      => open,

      -- PI GPIO

      i_GPIO               => (others => '1'),
      o_GPIO               => open,
      o_GPIO_EN            => open
   );

   audio_L <= (others => '1') when zxn_audio_L_pre(12) = '1' else zxn_audio_L_pre(11 downto 0);
   audio_R <= (others => '1') when zxn_audio_R_pre(12) = '1' else zxn_audio_R_pre(11 downto 0);
	
	zxn_audio_L <= (others => '1') when zxn_audio_L_pre(12) = '1' else zxn_audio_L_pre(11 downto 0);
   zxn_audio_R <= (others => '1') when zxn_audio_R_pre(12) = '1' else zxn_audio_R_pre(11 downto 0);
	
--	zxn_rgb<=RGB;
--   zxn_rgb_vs_n<=RGB_VS_n;
--   zxn_rgb_hs_n<=RGB_HS_n;
--   zxn_rgb_vb_n<=RGB_VB_n;
--   zxn_rgb_hb_n<=RGB_HB_n;
	
	RGB <= zxn_rgb;
   RGB_VS_n <= zxn_rgb_vs_n;
   RGB_HS_n <= zxn_rgb_hs_n;
   RGB_VB_n <= zxn_rgb_vb_n;
   RGB_HB_n <= zxn_rgb_hb_n;
	
	
		
   ear_port_i_q2 <=ear_port_i_m when tape_ready = '1' else ear_port_i_q;
--	zxn_joy_left2(10 downto 0) <= zxn_joy_left(10 downto 0) when joyl_real ='1' else joy_left(10 downto 0);
--	zxn_joy_right2(10 downto 0) <= zxn_joy_right(10 downto 0) when joyr_real ='1' else joy_right(10 downto 0);


      

end architecture;

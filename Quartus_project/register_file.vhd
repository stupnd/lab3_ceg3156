LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY register_file IS
    PORT(
        read_reg_1   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); 
        read_reg_2   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  
        write_reg    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  
        write_data   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); 
        Read_output_1: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
        Read_output_2: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  
    );
END register_file;

ARCHITECTURE structural OF register_file IS

    -- Component declaration for an 8-bit register (using the provided D latch)
    COMPONENT eightBitAsyncReg
        PORT(
            i_d      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            i_enable : IN  STD_LOGIC;
            o_q      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_qBar   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- 3-to-8 decoder: converts 3-bit address to eight one-hot enable signals
    COMPONENT decoder3to8
        PORT(
            i_addr : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_dec  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- 8-to-1 multiplexer for 8-bit data; ss one of eight 8-bit inputs
    COMPONENT mux8to1_8bit
        PORT(
            i0, i1, i2, i3, i4, i5, i6, i7 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            s                         : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_data                         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- Signal for write enables to each register (from the decoder)
    SIGNAL write_enables : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    -- Define an array type for the outputs of the eight registers
    TYPE reg_array IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_file_out : reg_array;
    
BEGIN
    -- Instantiate the 3-to-8 decoder to decode the write_reg address
    dec_inst: decoder3to8
        PORT MAP(
            i_addr => write_reg,
            o_dec  => write_enables
        );
        
    -- Instantiate eight 8-bit registers; each gets enabled according to write_enables.
    GEN_REG: FOR i IN 0 TO 7 GENERATE
        reg_inst: eightBitAsyncReg
            PORT MAP(
                i_d      => write_data,
                i_enable => write_enables(i),
                o_q      => reg_file_out(i),
                o_qBar   => OPEN  -- Unused output
            );
    END GENERATE;
    
    -- Two 8-to-1 multiplexers to s read outputs from the register file.
    mux_read1: mux8to1_8bit
        PORT MAP(
            i0     => reg_file_out(0),
            i1     => reg_file_out(1),
            i2     => reg_file_out(2),
            i3     => reg_file_out(3),
            i4     => reg_file_out(4),
            i5     => reg_file_out(5),
            i6     => reg_file_out(6),
            i7     => reg_file_out(7),
            s => read_reg_1,
            o_data => Read_output_1
        );
        
    mux_read2: mux8to1_8bit
        PORT MAP(
            i0     => reg_file_out(0),
            i1     => reg_file_out(1),
            i2     => reg_file_out(2),
            i3     => reg_file_out(3),
            i4     => reg_file_out(4),
            i5     => reg_file_out(5),
            i6     => reg_file_out(6),
            i7     => reg_file_out(7),
            s => read_reg_2,
            o_data => Read_output_2
        );
        
END structural;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY register_file IS
    PORT(
        read_reg_1   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0); 
        read_reg_2   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  
        write_reg    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  
        write_data   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); 
        Read_output_1: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
        Read_output_2: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
        reset        : IN  STD_LOGIC  -- New reset input
    );
END register_file;

ARCHITECTURE structural OF register_file IS

    -- Component declaration for an 8-bit register (using the provided D latch)
    COMPONENT eightBitAsyncReg
        PORT(
            i_d      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            i_enable : IN  STD_LOGIC;
            o_q      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            o_qBar   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- 3-to-8 decoder: converts 3-bit address to eight one-hot enable signals
    COMPONENT decoder3to8
        PORT(
            i_addr : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_dec  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- 8-to-1 multiplexer for 8-bit data; selects one of eight 8-bit inputs
    COMPONENT mux8to1_8bit
        PORT(
            i0, i1, i2, i3, i4, i5, i6, i7 : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            s                                 : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_data                             : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    
    -- Signal for write enables to each register (from the decoder)
    SIGNAL write_enables : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
    -- Define an array type for the outputs of the eight registers
    TYPE reg_array IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_file_out : reg_array;

    -- Define the default values to set when reset is active (0)
    SIGNAL reset_values : reg_array := (
        "00000001", -- Register 0 -> 1
        "00000010", -- Register 1 -> 2
        "00000011", -- Register 2 -> 3
        "00000100", -- Register 3 -> 4
        "00000101", -- Register 4 -> 5
        "00000110", -- Register 5 -> 6
        "00000111", -- Register 6 -> 7
        "00001000"  -- Register 7 -> 8
    );

BEGIN
    -- Instantiate the 3-to-8 decoder to decode the write_reg address
    dec_inst: decoder3to8
        PORT MAP(
            i_addr => write_reg,
            o_dec  => write_enables
        );
        
    -- Instantiate eight 8-bit registers; each gets enabled according to write_enables.
    GEN_REG: FOR i IN 0 TO 7 GENERATE
        reg_inst: eightBitAsyncReg
            PORT MAP(
                i_d      => (reset = '0') ? reset_values(i) : write_data,  -- Use reset values when reset = 0, else use write_data
                i_enable => write_enables(i),
                o_q      => reg_file_out(i),
                o_qBar   => OPEN  -- Unused output
            );
    END GENERATE;
    
    -- Two 8-to-1 multiplexers to read outputs from the register file.
    mux_read1: mux8to1_8bit
        PORT MAP(
            i0     => reg_file_out(0),
            i1     => reg_file_out(1),
            i2     => reg_file_out(2),
            i3     => reg_file_out(3),
            i4     => reg_file_out(4),
            i5     => reg_file_out(5),
            i6     => reg_file_out(6),
            i7     => reg_file_out(7),
            s => read_reg_1,
            o_data => Read_output_1
        );
        
    mux_read2: mux8to1_8bit
        PORT MAP(
            i0     => reg_file_out(0),
            i1     => reg_file_out(1),
            i2     => reg_file_out(2),
            i3     => reg_file_out(3),
            i4     => reg_file_out(4),
            i5     => reg_file_out(5),
            i6     => reg_file_out(6),
            i7     => reg_file_out(7),
            s => read_reg_2,
            o_data => Read_output_2
        );
        
END structural;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY thirtyTwoBitALU IS
    PORT(
        A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- ALU_control mapping:
        -- 000 : AND
        -- 001 : OR
        -- 010 : ADD
        -- 110 : SUB
        -- 111 : Set Less Than
        ALU_control : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        zero : OUT STD_LOGIC;
        result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        result8 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END thirtyTwoBitALU;

ARCHITECTURE Structural OF thirtyTwoBitALU IS

    -- Sub-components and signals
    COMPONENT thirtyTwoBitCLA IS
        PORT(
            A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sub : IN STD_LOGIC;
            sum : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            cout : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT twoBy32To32Mux IS
        PORT(
            A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sel : IN STD_LOGIC;
            result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT or32 IS
        PORT(
            in_vec : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_or : OUT STD_LOGIC
        );
    END COMPONENT;

    signal and_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal or_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mathematical_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal logical_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal arithmetic_output : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal to_sub_or_not_to_sub : STD_LOGIC;
    signal set_less_than : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal final : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal not_zero : STD_LOGIC;
    signal arithmetic_sel : STD_LOGIC;  -- selects between ADD/SUB result and set-less-than result

BEGIN

    -------------------------------
    -- Logical Operations Section
    -------------------------------
    and_result <= A AND B;
    or_result <= A OR B;
    -- For logical operations the least-significant bit determines the operation:
    -- ALU_control = "000" selects AND (0) and "001" selects OR (1)
    logical_select_mux: twoBy32To32Mux PORT MAP(
        A => and_result,
        B => or_result,
        sel => ALU_control(0),
        result => logical_output
    );

    -------------------------------
    -- Arithmetic Operations Section
    -------------------------------
    -- For arithmetic operations (when ALU_control(1) = '1'):
    --   ADD is "010" → ALU_control(2) = '0'
    --   SUB is "110" → ALU_control(2) = '1'
    --   Set Less Than is "111" → ALU_control(2) = '1'
    --
    -- Determine if subtraction is required (SUB or Set Less Than)
    to_sub_or_not_to_sub <= ALU_control(2);

    arithmetic_unit: thirtyTwoBitCLA PORT MAP(
        A => A,
        B => B,
        sub => to_sub_or_not_to_sub,
        sum => mathematical_result,
        cout => open
    );

    -- Calculate set less than result:
    -- The result is '1' (in the LSB) if A < B (i.e. the subtraction result is negative)
    set_less_than <= (31 DOWNTO 1 => '0') & mathematical_result(31);

    -- For arithmetic operations, choose between the normal result (for ADD and SUB)
    -- and the set-less-than result. Use ALU_control(0) in combination with ALU_control(1):
    --   For ADD ("010"): ALU_control = 0 1 0 → (ALU_control(1)= '1' and ALU_control(0)= '0') → select mathematical_result.
    --   For SUB ("110"): ALU_control = 1 1 0 → (ALU_control(1)= '1' and ALU_control(0)= '0') → select mathematical_result.
    --   For SLT ("111"): ALU_control = 1 1 1 → (ALU_control(1)= '1' and ALU_control(0)= '1') → select set_less_than.
    arithmetic_sel <= ALU_control(0) AND ALU_control(1);

    arithmetic_select_mux: twoBy32To32Mux PORT MAP(
        A => mathematical_result,
        B => set_less_than,
        sel => arithmetic_sel,
        result => arithmetic_output
    );

    -------------------------------
    -- Top-Level Multiplexer
    -------------------------------
    -- Use ALU_control(1) to choose between a logical operation (when '0') and an arithmetic operation (when '1')
    top_level_mux: twoBy32To32Mux PORT MAP(
        A => logical_output,        -- when ALU_control(1) = '0'
        B => arithmetic_output,     -- when ALU_control(1) = '1'
        sel => ALU_control(1),
        result => final
    );

    -------------------------------
    -- Zero Detection
    -------------------------------
    zero_calc: or32 PORT MAP(
        in_vec => final,
        out_or => not_zero
    );

    zero <= not not_zero;
    result <= final;
    result8 <= final(7 DOWNTO 0);
END Structural;

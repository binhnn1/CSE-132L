LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY hazard_control IS 
	PORT (
		rsE				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rtE				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		wrE				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		wrM				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		wrW				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rsD				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rtD				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rwE				: IN STD_LOGIC;
		rwM				: IN STD_LOGIC;
		rwW				: IN STD_LOGIC;
		brD				: IN STD_LOGIC;
		mtrE				: IN STD_LOGIC;
		mtrM			: IN STD_LOGIC;
		fwdAD			: OUT STD_LOGIC;
		fwdBD			: OUT STD_LOGIC;
		fwdAE			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		fwdBE			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		StallF			: OUT STD_LOGIC;
		StallD			: OUT STD_LOGIC;
		FlushE			: OUT STD_LOGIC
	);
END ENTITY hazard_control;

ARCHITECTURE logic OF hazard_control IS
SIGNAL lwstall, branchstall : STD_LOGIC;
BEGIN
	lwstall <= '1' WHEN (((rsD = rtE) OR (rtD = rtE)) AND mtrE = '1') ELSE '0';
	branchstall <= '1' WHEN ((brD = '1' AND rwE = '1' AND ((wrE = rsD) OR (wrE = rtD))) OR 
											(brD = '1' AND mtrM = '1' AND ((wrM = rsD) OR (wrM = rtD)))) ELSE '0';
	StallF <= lwstall OR branchstall;
	StallD <= lwstall OR branchstall;
	FlushE <= lwstall OR branchstall;
	
	
	PROCESS(rsE, rtE, wrM, wrW, rsD, rtD, rwM, rwW, mtrE)
	BEGIN
	
		IF (rsD /= "00000" AND rsD = wrM AND rwM = '1') THEN
			fwdAD <= '1';
		ELSE
			fwdAD <= '0';
		END IF;
			
		IF (rtD /= "00000" AND rtD = wrM AND rwM = '1') THEN
			fwdBD <= '1';
		ELSE
			fwdBD <= '0';
		END IF;
		
		-- ALUInput1
		IF (rsE /= "00000" AND rsE = wrM AND rwM = '1') THEN
		-- Forwarding from AluOutM
			fwdAE <= "10";
		ELSIF (rsE /= "00000" AND rsE = wrW AND rwW = '1') THEN
		-- Forwading from RamOutW
			fwdAE <= "01";
		ELSE
			fwdAE <= "00";
		END IF;
		
		-- ALUInput2
		IF (rtE /= "00000" AND rtE = wrM AND rwM = '1') THEN
			fwdBE <= "10";
		ELSIF (rtE /= "00000" AND rtE = wrW AND rwW = '1') THEN
			fwdBE <= "01";
		ELSE
			fwdBE <= "00";
		END IF;
		
	END PROCESS;
END ARCHITECTURE logic;
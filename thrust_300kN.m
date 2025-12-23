thrust = 300;
T3 = 830;
P3 = 4300;
T4 = 1650;
m_a = 98;

Cp_air = 1000;       
Cp_gas = 1150;     
LHV = 43.6 * 10^6;  

m_f = m_a * (Cp_gas * T4 - Cp_air * T3) / (LHV - (Cp_gas * T4));

mass_fuel_stoich = (11 * 12) + (23 * 1.008); 
moles_O2_stoich = 16.75;
moles_N2_stoich = 16.75 * 3.76;
mass_air_stoich = (moles_O2_stoich * 32) + (moles_N2_stoich * (14.01 * 2));

FAR_stoich = mass_fuel_stoich / mass_air_stoich;
FAR_actual = m_f ./ m_a; 

phi = FAR_actual / FAR_stoich;
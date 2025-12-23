clear all; close all; clc;

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

FA_ratio_stoich = mass_fuel_stoich / mass_air_stoich;
FA_ratio_actual = m_f / m_a; 

phi = FA_ratio_actual / FA_ratio_stoich;

% rich zone phi = 1.5
phi_rich = 1.5; 
FA_ratio_rich = phi_rich * FA_ratio_stoich;
m_a_total_rich = m_f / FA_ratio_rich;
% m_a_total_rich == 0.12 * m_a + X1 so ...
X1 = m_a_total_rich - 0.12 * m_a;

% quench zone phi = 0.7
phi_quench = 0.7; 
FA_ratio_quench = phi_quench * FA_ratio_stoich;
m_a_total_quench = m_f / FA_ratio_quench;
X2 = m_a_total_quench - m_a_total_rich;


X3 = m_a - m_a_total_quench;
m_a_total_lean = X3 + m_a_total_quench;

% --- Print Results for Report ---
fprintf('\n=================================================\n');
fprintf('       AIRFLOW DISTRIBUTION REPORT (300 kN)\n');
fprintf('=================================================\n');

fprintf('Total Airflow (Wa):              %8.4f kg/s\n', m_a);
fprintf('Total Fuel Flow (Wf):            %8.4f kg/s\n', m_f);
fprintf('Stoichiometric F/A Ratio:        %8.4f\n', FA_ratio_stoich);
fprintf('-------------------------------------------------\n');

% 1. RICH ZONE (Target Phi = 1.5)
fprintf('1. RICH ZONE SPLIT (Phi = 1.5)\n');
fprintf('   Total Air Required:           %8.4f kg/s\n', m_a_total_rich);
fprintf('   -> Snout Air (12%% fixed):     %8.4f kg/s\n', 0.12 * m_a);
fprintf('   -> Rich Holes (X1):           %8.4f kg/s\n', X1);
fprintf('\n');

% 2. QUENCH ZONE (Target Phi = 0.7)
fprintf('2. QUENCH ZONE SPLIT (Target Phi = 0.7)\n');
fprintf('   Total Air at Quench Point:    %8.4f kg/s\n', m_a_total_quench);
fprintf('   -> Quench Holes (X2):         %8.4f kg/s  <-- (Added Air)\n');
fprintf('\n');

% 3. DILUTION ZONE
fprintf('3. DILUTION ZONE SPLIT\n');
fprintf('   -> Dilution Holes (X3/Rest):  %8.4f kg/s\n', X3);
fprintf('-------------------------------------------------\n');

% Verification
sum_check = (0.12 * m_a) + X1 + X2 + X3;
fprintf('Sum Check (Should equal Wa):     %8.4f kg/s\n', sum_check);
fprintf('=================================================\n');


LHV_rich = 23.6 * 10^6; % LHV for phi > 1
T_ad_rich = (m_a_total_rich * Cp_air * T3 + m_f * LHV_rich) / ((m_a_total_rich + m_f) * Cp_gas);

T_ad_quench = (m_a_total_quench * Cp_air * T3 + m_f * LHV) / ((m_a_total_quench + m_f) * Cp_gas);

T_ad_lean = (m_a_total_lean * Cp_air * T3 + m_f * LHV) / ((m_a_total_lean + m_f) * Cp_gas);

fprintf('\n=================================================\n');
fprintf('   ADIABATIC FLAME TEMPERATURE REPORT\n');
fprintf('=================================================\n');
fprintf('Reference Conditions:\n');
fprintf('   Inlet Temp (T3):              %8.2f K\n', T3);
fprintf('   Standard LHV (Complete):      %8.2f MJ/kg\n', LHV/1e6);
fprintf('   Rich LHV (Incomplete):        %8.2f MJ/kg\n', LHV_rich/1e6);
fprintf('-------------------------------------------------\n');

% 1. RICH ZONE
fprintf('1. RICH ZONE (Phi=1.5)\n');
fprintf('   Status: Incomplete Combustion (CO produced)\n');
fprintf('   Adiabatic Flame Temp:         %8.2f K\n', T_ad_rich);
fprintf('\n');

% 2. QUENCH ZONE
fprintf('2. QUENCH ZONE (Phi=0.7)\n');
fprintf('   Status: Complete Combustion (CO -> CO2)\n');
fprintf('   Adiabatic Flame Temp:         %8.2f K\n', T_ad_quench);
fprintf('\n');

% 3. LEAN / EXIT ZONE
fprintf('3. DILUTION / EXIT ZONE (Overall)\n');
fprintf('   Status: Diluted with remaining air\n');
fprintf('   Adiabatic Flame Temp:         %8.2f K\n', T_ad_lean);
fprintf('   (Compare to Actual T4:        %8.2f K)\n', T4);
fprintf('=================================================\n');
clear all; close all; clc;

thrust = 300;   % [kN]
T3     = 830;   % [K]
P3     = 4300;  % [kPa]
T4     = 1650;  % [K]
m_a    = 98;    % [kg/s]

% Constants
Cp_air = 1000;       
Cp_gas = 1150;     
LHV = 43.6 * 10^6;  

% % % % % % % % % % % % % % Fuel massflow % % % % % % % % % % % % % % % % %

m_f = m_a * (Cp_gas * T4 - Cp_air * T3) / (LHV - (Cp_gas * T4));

% % % % % % % % % % % % Equivalence Ratio % % % % % % % % % % % % % % % % %
% Air is modelled as a mixture of ideal gases:
% -> 79% in volume is N2
% -> 21% in volume is O2

% Air mass per a single fuel mole 
moles_O2 = 16.75;
moles_N2 = 16.75 * 3.7619;
mass_air = (moles_O2 * 32) + (moles_N2 * (14.01 * 2));

% Single fuel mole mass
mass_fuel = (11 * 12) + (23 * 1.008); 

% Stechiometric Fuel-to-Air ratio
FA_ref = mass_fuel / mass_air;

% Actual Fuel-to-Air ratio
FA_actual = m_f ./ m_a; 

% Equivalence ratio
phi = FA_actual ./ FA_ref;

% Single burner massflow
n_burner = 18;
m_a_burner = m_a / n_burner;
m_f_burner = m_f / n_burner;

% % % % % % % % % % % % % % % % Rich Burn % % % % % % % % % % % % % % % % %
phi_rich = 1.5; 
FA_rich  = phi_rich * FA_ref;
m_a_rich = m_f_burner / FA_rich;

m1 = m_a_rich - 0.12 * m_a_burner;
x1 = m1 / m_a_burner;

% % % % % % % % % % % % % % % Quick Quench % % % % % % % % % % % % % % % % 
phi_quench = 0.7; 
FA_quench = phi_quench * FA_ref;
m_a_quench = m_f_burner / FA_quench;
m2 = m_a_quench - m_a_rich;
x2 = m2 / m_a_burner;

% % % % % % % % % % % % % % % % Lean Burn % % % % % % % % % % % % % % % % %
m3 = m_a_burner - m_a_quench;
x3 = m3 / m_a_burner;
m_a_lean = m3 + m_a_quench;

FA_lean = m_f_burner / m_a_lean;
phi_lean = FA_lean / FA_ref;

% % % % % % % % % % % Adiabatic Flame Temperature % % % % % % % % % % % % %
LHV_rich = 23.6 * 10^6; % LHV for phi > 1
T_ad_rich = (m_a_rich * Cp_air * T3 + m_f_burner * LHV_rich) / ((m_a_rich + m_f_burner) * Cp_gas);

T_ad_quench = (m_a_quench * Cp_air * T3 + m_f_burner * LHV) / ((m_a_quench + m_f_burner) * Cp_gas);

T_ad_lean = (m_a_lean * Cp_air * T3 + m_f_burner * LHV) / ((m_a_lean + m_f_burner) * Cp_gas);

% % % % % % % % % % % % % % % % % Volume % % % % % % % % % % % % % % % % %
t_residence = 6e-3;

% Assumption: rich = 30%, quench = 15% and lean = 55%
t_rich   = t_residence * 0.3;
t_quench = t_residence * 0.15;
t_lean   = t_residence * 0.55;

R = 287;
P = P3 * 10^3;

% Rich Zone
Q_rich = (m_a_rich + m_f_burner) * R * T_ad_rich / P;

% Quench Zone
Q_quench = (m_a_quench + m_f_burner) * R * T_ad_quench / P;

% Lean Zone
Q_lean = (m_a_lean + m_f_burner) * R * T_ad_lean / P;

% Overall
V_burner = t_rich * Q_rich + t_quench * Q_quench + t_lean * Q_lean;

% % % % % % % % % % % % % % % Heat Density % % % % % % % % % % % % % % % %
heat_density = m_f_burner * LHV / 1e6 / V_burner;

% --- Print Results for Report ---
fprintf('\n=================================================\n');
fprintf('       AIRFLOW DISTRIBUTION REPORT (300 kN)\n');
fprintf('=================================================\n');

fprintf('Total Airflow:\t\t\t%.2f kg/s\n', m_a);
fprintf('Total Fuel Flow:\t\t%.2f kg/s\n', m_f);
fprintf('Stoichiometric F/A Ratio:\t%.2f\n', FA_ref);
fprintf('-------------------------------------------------\n');

% 1. RICH ZONE (Target Phi = 1.5)
fprintf('1. RICH ZONE SPLIT\n');
fprintf('Total Air Required:\t\t%.4f kg/s\n', m_a_rich);
fprintf('  -> Phi:\t\t\t%.2f\n',phi_rich);
fprintf('  -> Snout Air:\t\t\t12 %%\n');
fprintf('  -> Rich Holes:\t\t%.1f %%\n', x1*100);
fprintf('\n');

% 2. QUENCH ZONE (Target Phi = 0.7)
fprintf('2. QUENCH ZONE SPLIT\n');
fprintf('Total Air Required:\t\t%.4f kg/s\n', m_a_quench);
fprintf('  -> Phi:\t\t\t%.2f\n',phi_quench);
fprintf('  -> Quench Holes:\t\t%.1f %%\n', x2*100);
fprintf('\n');

% 3. DILUTION ZONE
fprintf('3. DILUTION ZONE SPLIT\n');
fprintf('Total Air Required:\t\t%.4f kg/s\n', m_a_lean);
fprintf('  -> Phi:\t\t\t%.2f\n',phi_lean);
fprintf('  -> Lean Holes:\t\t%.1f %%\n', x3*100);

% Verification
sum_check = n_burner * ((0.12 * m_a_burner) + m1 + m2 + m3);
err = sum_check - m_a;
if  err ~= 0 
    error('Inconsistent diluition!');
end


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

% Burner volume 
fprintf('\n=================================================\n');
fprintf('   BURNER VOLUME REPORT\n');
fprintf('=================================================\n');
fprintf('Burner volume:\t\t\t%8.3f l\n',V_burner*1000);

% Heat density
fprintf('\n=================================================\n');
fprintf('   HEAT DENSITY REPORT\n');
fprintf('=================================================\n');
fprintf('Heat density:\t\t\t%8.1f MW/m^3\n',heat_density);
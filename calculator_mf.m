clear all; close all; clc;

%        idle  50    100   200   300   
thrust = [25;  50;   100;  200;  300];  % [kN]
T3     = [480; 580;  660;  760;  830];  % [K]
P3     = [650; 1000; 1750; 3000; 4300]; % [kPa]
T4     = [960; 1050; 1225; 1450; 1650]; % [K]
m_a    = [20;  29;   47;   76;   98];   % [kg/s]
m_a_burner = m_a / 18;

% Constants
Cp_air = 1000;      % [J/kg K]  
Cp_gas = 1150;      % [J/kg K]
LHV = 43.6 * 10^6;  % [J/kg]

% mf = ma * (Cpg*T4 - Cpa*T3) / (LHV - Cpg*T4)

% % % % % % % % % % % % % % Fuel massflow % % % % % % % % % % % % % % % % %

m_f = m_a .* (Cp_gas .* T4 - Cp_air .* T3) ./ (LHV - (Cp_gas .* T4));
m_f_burner = m_f / 18;

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

% NOTE: following the proposed definition Phi > 1 is fuel rich mixture, Phi < 1 is
% oxydizer rich mixture

t_residence = 6e-3;
rho = P3' * 10^3 ./ (287 * T4');
Q_burner = (m_a_burner + m_f_burner) ./ rho';
V_burner = Q_burner * t_residence;

% % % % % % % % % % % % % % % Heat Density % % % % % % % % % % % % % % % %
heat_density = m_f_burner .* LHV ./ 1e6 ./ V_burner;

% --- Results ---
fprintf('\nThrust(kN)\tAirFlow(kg/s)\tFuelFlow(kg/s)\tFAR_actual\tPhi\tHeat density(MW/m^3)\n');
fprintf('----------------------------------------------------------------------------------\n');

for i = 1:length(thrust)
    fprintf('%.0f\t\t%.2f\t\t%.4f\t\t%.5f\t\t%.4f\t\t%.4f\n', ...
        thrust(i), m_a(i), m_f(i), FA_actual(i), phi(i), heat_density(i));
end



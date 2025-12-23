thrust = [25; 50; 100; 200; 300;]; % 25 is idle
T3 = [480; 580; 660; 760; 830;];
P3 = [650; 1000; 1750; 3000; 4300;];
T4 = [960; 1050; 1225; 1450; 1650;];
m_a = [20; 29; 47; 76; 98;];

% --- Constants ---
Cp_air = 1000;       
Cp_gas = 1150;     
LHV = 43.6 * 10^6;  

% mf = ma * (Cpg*T4 - Cpa*T3) / (LHV - Cpg*T4)
m_f = m_a .* (Cp_gas .* T4 - Cp_air .* T3) ./ (LHV - (Cp_gas .* T4));



mass_fuel_stoich = (11 * 12) + (23 * 1.008); 
moles_O2_stoich = 16.75;
moles_N2_stoich = 16.75 * 3.76;
mass_air_stoich = (moles_O2_stoich * 32) + (moles_N2_stoich * (14.01 * 2));

FAR_stoich = mass_fuel_stoich / mass_air_stoich;

FAR_actual = m_f ./ m_a; 

phi = FAR_actual / FAR_stoich;

% --- Results ---
fprintf('\nThrust(kN)\tAirFlow(kg/s)\tFuelFlow(kg/s)\tFAR_actual\tPhi\n');
fprintf('--------------------------------------------------------------------------\n');

for i = 1:length(thrust)
    fprintf('%.0f\t\t%.2f\t\t%.4f\t\t%.5f\t\t%.4f\n', ...
        thrust(i), m_a(i), m_f(i), FAR_actual(i), phi(i));
end
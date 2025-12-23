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

% --- Results ---
disp('   Thrust(kN)   AirFlow(kg/s)   FuelFlow(kg/s)');
disp([thrust, m_a, m_f]);
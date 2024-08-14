% Input data required for fuel cycle
% Fuel cycle advancements scenario (for a detailed description of this
% scenario see Meschini et al., "Modeling and analysis of the tritium fuel cycle for ARC- and STEP-Class D-T fusion power plants", 2023)
% Residence times [s]
tau1 = 1.25*3600; % Blanket
tau2 = 1*24*3600; % TES
tau3 = 1000; % FW
tau4 = 1000; % Divertor
tau5 = 1000; % HX
tau6 = 3600; % Detritiation system
tau7 = 600; % Vacuum pump 
tau8 = 0.1*3600; % Fuel clean-up - tau8+tau9 = 4h from Abdou's paper
tau9 = 0.9*3600; % ISS -  tau8+tau9 = 4h from Abdou's paper
tau10 = 1*3600;
tau12 = 100; % Membrane separation
% Decay constant
lambda = 1.73e-9; %12.33 y half-life
% Non-radioactive losses fraction
epsi = 1e-4;
% Effective residence time
T1 = 1/((1 + epsi)/tau1 + lambda); % Blanket
T2 = 1/((1 + epsi)/tau2 + lambda); % TES
T3 = 1/((1 + 0)/tau3 + lambda); % FW
T4 = 1/((1 + 0)/tau4 + lambda); % Divertor
T5 = 1/((1 + epsi)/tau5 + lambda); % HX
T6 = 1/((1 + epsi)/tau6 + lambda); % Detritiation system
T7 = 1/((1 + epsi)/tau7 + lambda); % Vacuum pump
T8 = 1/((1 + epsi)/tau8 + lambda); % Fuel clean-up
T9 = 1/((1 + epsi)/tau9 + lambda); % ISS
T12 = 1/((1 + epsi)/tau12 + lambda);

% Flow rate fractions
% From plasma to components
fp3 = 1e-4;
fp4 = 1e-4;

%From component to component
f51 = 0.33; % HX to blanket
f53 = 0.33; % HX to FW
f56 = 1e-4; % HX to DS
f54 = 1 - f51 - f53 - f56; % HX to div
f96 = 0.1; % ISS to DS
f_dir = 0.7; % DIR fraction

% Components' efficiency
eta2 = 0.95;
eta6 = 0.95;

% General parameters
N_dot = 9.3e-7; % Tritium burnt [kg/s]
TBE = 0.02; % Tritium burn efficiency

% Reserve inventory
q = 0.25; % fraction of FC failing
t_res = 3600 * 24; % reserve time
AF = 0.90; % for AF_model, use 0-100, for non AF_models, use 0-1;
I_reserve = N_dot / TBE * q * t_res; %  reserve inventory [kg]
t_d = 2;
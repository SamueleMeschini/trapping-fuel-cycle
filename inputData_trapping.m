relaxation_coefficient = 1e8; % increase the characteristic time of 
% trapping/detrapping to avoid stiffness. NOTE: this affects the transient
% evolution, but not the magnitude of the trapped inventory. The timescale
% is still so quick that it does not have any effects on the results.

% Define trapping input data
N_a = 6.022e23;
PM_tungsten = 183.8;
PM_tritium = 3;
nu_0 = 1e13;
k_B = 8.6e-5; % ev/K 

% Tungsten
layer_thickness_induced_traps = 2.5e-6; % m
FW_thickness = 1e-3; % m
rho_tungsten = 19.3; %g/cm3
V_tungsten = 0.35e6; % cm3
T_tungsten = 1000; % K
n_tungsten = (rho_tungsten*1e6) / PM_tungsten * N_a; % m^-3
E_trap_W_intrinsic = 1; % eV
E_trap_W_extrinsic = [1.15, 1.35, 1.65, 1.85, 2.05]; % eV
trap_creation_factor_W = [9* layer_thickness_induced_traps/FW_thickness, 4.2, 2.5, 5, 1]*1e26/n_tungsten ; % Damage occurs only in the small layer. Average over all the FW in this way
n_tungsten_max = [6.9* layer_thickness_induced_traps/FW_thickness, 7, 6, 4.7, 2]*1e25/n_tungsten; % REF James et al. 2023 - amage occurs only in the small layer. Average over all the FW in this way
% n_max_tungsten = [0.035e-2, 0.1e-2, 0.2e-2, 0.05e-2] % REF: Odille et al.
damage_rate = 20/(8760*3600); %dpa/s
A_0 = 6.18e-3;
E_annealing = [0.24, 0.3]; % eV
k_B = 8.6e-5; % ev/K 
E_trap_W = [E_trap_W_intrinsic, E_trap_W_extrinsic];
% Tungsten
% n_trap_tungsten = [0.13e-2, 0.035e-2, 0.1e-2, 0.2e-2, 0.05e-2];

nu_detrap = nu_0 * exp(-E_trap_W/(k_B * T_tungsten)); % detrapping rate
tau_detrap_tungsten = 1 ./ nu_detrap* relaxation_coefficient;
D_tungsten = 4.1e-7 /sqrt(3) * exp(-0.39/(k_B * T_tungsten)) % Diffusion coefficient in tungsten - Dividide by sqrt(Isotope mass)
a_tungsten = 316e-12; % m - lattice constant
dd = a_tungsten/2/sqrt(2);
nu_trap = D_tungsten / dd^2;
tau_trap_tungsten = 1/nu_trap * relaxation_coefficient;
n_solute_tungsten = 6; % Available site for mobile tritium
n_trap_tungsten_intrinsic = 3.5e-4;
% n_trap_tungsten_intrinsic = 0.13e-2; 
m_u = 1.6e-27; 
M_tungsten = V_tungsten * rho_tungsten/1e3; % kg

% V-Cr-Ti 
T_structural = 900; % K 

rho_vcrti = 6.1; % V-Cr-Ti alloy g/cm3 - REF: D.L. Smith, et al., 
% Vanadium-base alloys for fusion reactor applications — a review, 
% Journal of Nuclear Materials, vol. 135, pp. 125-139, 1985
PM_vcrti = 47*0.15+50*.7+52*0.15; % VCrTi
E_trap_vcrti = 0.5; % Random number for the moment
D_vcrti = 7.5e-8 * exp(-0.13/(k_B * T_structural)); % Diffusion coefficient in VCrTi - REF: Hashizume, 2007
a_vcrti = 303e-12; % m - lattice constant. REF: I Kurzina et al 2019 J. Phys.: Conf. Ser. 1145 012051
n_trap_vcrti = 1e-4;
n_solute_vcrti = 6;
% NOTE: the trapping energy is unknown

% Inconel-718
rho_inconel = 8.2 ;
PM_inconel = 58*0.55 + 52*0.2 + 0.25*56;
E_trap_inconel = 0.26;
D_inconel = 1.07e-6 / sqrt(3)* exp(-0.26/(k_B * T_structural));
a_inconel = 360e-12;
n_trap_inconel = 1e-4;
n_solute_inconel = 12;

% Eurofer 97 - REF: Esteban et al. Journal of Nuclear Materials, 367-370 (2007), pp. 473-477
rho_eurofer = 7.8;
PM_eurofer = 55.6;
n_eurofer = (rho_eurofer * 1e6) / PM_eurofer * N_a
E_trap_eurofer = 0.45;
D_eurofer = 4.57e-7 / sqrt(3) * exp(-0.23/(k_B*T_structural));
a_eurofer = 286e-12; % REF: https://journals.aps.org/pr/pdf/10.1103/PhysRev.25.753 for Fe
n_trap_eurofer = 1.3e25/n_eurofer;
n_solute_eurofer = 6;


PM_structural = PM_vcrti;
rho_structural = rho_vcrti;
V_structural = 3.5e6; % cm3 - REF: D. Pettinari
nu_detrap_structural = nu_0 * exp(-E_trap_vcrti/(k_B * T_structural)); % detrapping rate
tau_detrap_structural = 1 / nu_detrap_structural* relaxation_coefficient;
D_structural = D_vcrti;
a_structural = a_vcrti; % m - lattice constant. REF: I Kurzina et al 2019 J. Phys.: Conf. Ser. 1145 012051
dd_structural = a_structural/2/sqrt(2);
nu_trap_structural = D_structural / dd_structural^2;
tau_trap_structural = 1/nu_trap_structural * relaxation_coefficient;
n_structural = (rho_structural*1e6) / PM_structural * N_a;
n_solute_structural = n_solute_vcrti; % Available site for mobile tritium - Assume that V-Cr-TI is BCC
n_trap_structural= n_trap_vcrti;
M_structural = V_structural * rho_structural/1e3; % kg
clear all
tic
% Activate trapping
trapping = true;
% Load input data
run('inputData.m')

% Do not store data from inspector - avoid memory issues 
Simulink.sdi.setAutoArchiveMode(false);
Simulink.sdi.setArchiveRunLimit(0);

% Define model to be run
if trapping
    model = 'fuelCycle_w_trapping_multilevel.slx';
    run('inputData_trapping.m')
else
    model = "fuelCycle_avg_AF.slx";
end
TBR_accuracy= 0.001; % accuracy when computing the required TBR 
inventory_accuracy = 0.01; % accuracy when computing start-up inventory [kg]
sim_time = 2.5*8760*3600; % simulation time [s]
runMode = "single"   % single, iteration or parametric analysis
parametric_variable = 'f_p_trap'; % name of the variable if performing parametric analysis

TBR = 1.096 % TBR - If runMode = "single" this is fixed
            %       If runMode = "iteration" this is the initial guess
I_s_0 = 1.85; % startup inventory [kg] - If runMode = "single" this is fixed
             %                          If runMode = "iteration" this is the initial guess             
% If you know the required TBR and the start-up inventory, run in "single"
% mode. If you don't know them, run in "iteration" mode, find the required
% TBR and the start-up inventory for a given configuration, and then run a
% "single" simulation to extract the inventories (and wathever variable required) from the model. 

% disp('ATTENTION: ')

if strcmp(runMode,"single")
    %Single simulation with fixed TBR and start-up inventory
    out = sim(model); 
    
    
    %     in this case we save the tritium inventories from some of the FC
    %     components and store them in a matrix. Each inventory is accessible
    %     by out.I_N, where N is the component number as described in the
    %     paper. 
    if trapping == false
      header = {'time [s]',...
            'blanket inventory [kg]', ...
            'TES inventory [kg]', ...
            'ISS inventory [kg]', ...
            'storage inventory [kg]', ... 
            'FW inventory [kg]', ...
            'div inventory [kg]'};
        writecell(header,'results/inventories.csv', "WriteMode","overwrite", "Delimiter",",");
        writematrix([out.tout, out.I_1, out.I_2, out.I_9, out.I_11, out.I_4, out.I_3], 'results/inventories.csv', "WriteMode","append", "Delimiter",",");
    
    else
    
        header = {'time [s]',...
            'blanket inventory [kg]', ...
            'TES inventory [kg]', ...
            'ISS inventory [kg]', ...
            'storage inventory [kg]', ... 
            'FW inventory [kg]', ...
            'div inventory [kg]', ...
            'blanket inventory trapped [kg]', ...
            'FW inventory traped [kg]', ...
            'div inventory trapped [kg]'};
        writecell(header,'results/inventories.csv', "WriteMode","overwrite", "Delimiter",",");
        writematrix([out.tout, (out.I_1 + out.I_1_trapped), out.I_2, out.I_9, out.I_11, (out.I_4_trapped+out.I_4), (out.I_3_trapped+out.I_3), out.I_1, out.I_3, out.I_4], 'results/inventories.csv', "WriteMode","append", "Delimiter",",");
    end
% %     In this other case we set the reserve time to 0 and run a simulation
% %     to track the storage inventory without a reserve inventory
%     header = {'time [s]', 'storage inventory [kg]'};
%     writecell(header,'results/inflection_w_o_reserve.csv', "WriteMode","overwrite", "Delimiter",",");
%     writematrix([out.tout, out.I_11], 'results/inflection_w_o_reserve.csv', "WriteMode","append", "Delimiter",",");

elseif strcmp(runMode,"iteration")
    %Iterative search for the required TBR and start-up inventory
    if trapping
    utilities.find_tbr_w_trapping(I_s_0, I_reserve, t_d, TBR, model, TBR_accuracy, inventory_accuracy)

    else
    utilities.find_tbr(I_s_0, I_reserve, t_d, TBR, model, TBR_accuracy, inventory_accuracy)

    end

elseif strcmp(runMode,'parametric')
    if strcmp(parametric_variable,'TBE')
        mkdir(strcat('results/', parametric_variable,'td',string(t_d),'y'))
    else
        mkdir(strcat('results/', parametric_variable))
    end
    run(strcat('parametric_analysis_',parametric_variable,'.m'))
else
    fprintf("Enter a valid run mode \n")
end
toc
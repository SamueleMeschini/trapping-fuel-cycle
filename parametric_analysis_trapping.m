f_permanent_trap_array = [1e-7, 1e-8, 1e-9]; % Permanent trap fraction [-]
n_trap_array = [1e-2, 1e-3, 1e-4];

TBE = 2/100; % TBE [-]

for j=1:numel(n_trap_array)
    n_trap = n_trap_array(j);
    n_trap_structural = n_trap_array(j);
    % if n_trap==1e-8
    %     f_permanent_trap_array = [1e-7, 1e-6,];
    % else
    %     f_permanent_trap_array = [1e-7, 1e-6, 1e-5];
    % end

    for i=1:numel(f_permanent_trap_array)
        if n_trap==1e-8
            TBR = 1.08;
        else 
            TBR = 1.06;
        end 

        f_permanent_trap = f_permanent_trap_array(i);
        [out(i,j), I_startup(i,j), ~,~,~,~, I_div_trapped(i,j), I_FW_trapped(i,j)] = utilities.find_tbr(I_s_0, I_reserve, t_d, TBR, model, TBR_accuracy, inventory_accuracy);
        close_system(model); 
        Simulink.sdi.clear;

    end
    % f_permanent_trap_array = [1e-7, 1e-6, 1e-5];
    % f_permanent_trap_array = [0.01, 0.1, 0.9];
    header = {parametric_variable,'TBR_req','I_startup [kg]', 'I_div_trapped [kg]', 'I_FW_trapped [kg]'};
    writecell(header,strcat('results/',parametric_variable,'/','n_trap=',string(sprintf("%1.10f",n_trap)),'.csv'), "WriteMode","overwrite", 'Delimiter',','); % Use writecell because writematrix does not add the delimiter between strings 
    writematrix([(f_permanent_trap_array)',out(:,j), I_startup(:,j), I_div_trapped(:,j), I_FW_trapped(:,j)], strcat('results/',parametric_variable,'/','n_trap=',string(sprintf("%1.10f", n_trap)),'.csv'), "WriteMode","append");
end
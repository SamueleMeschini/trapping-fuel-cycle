f_p = [1e-4, 1e-3, 1e-2, 1e-1]; % Fraction of plasma to the walls and divertor
TBE_array = [5]/100; % TBE [-]

for j=1:numel(TBE_array)
    TBE = TBE_array(j);
    I_reserve = N_dot / TBE * q * t_res;
    for i=1:numel(f_p)
        if TBE == 0.005
            TBR = 1.12;
        elseif TBE == 0.01
            TBR = 1.15;
        elseif TBE == 0.02
            TBR = 1.087;
        else
            TBR = 1.048;           
        end
        I_s_0 = 0.8; 
        fp3 = f_p(i) ;
        fp4 = f_p(i) ;
        [out(i,j), I_startup(i,j), ~,~,~,~] = utilities.find_tbr_w_trapping(I_s_0, I_reserve, t_d, TBR, model, TBR_accuracy, inventory_accuracy);
        close_system(model); 
        Simulink.sdi.clear;

    end
    header = {parametric_variable,'TBR_req','I_startup [kg]'};
    writecell(header,strcat('results/',parametric_variable,'/','TBE=',string(sprintf("%1.1f",TBE*100)),'%.csv'), "WriteMode","overwrite", 'Delimiter',','); % Use writecell because writematrix does not add the delimiter between strings 
    writematrix([(f_p)',out(:,j), I_startup(:,j)], strcat('results/',parametric_variable,'/','TBE=',string(sprintf("%1.1f",TBE*100)),'%.csv'), "WriteMode","append");

end

classdef utilities
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        function [TBR, I_s_0, margin, blanket_inventory, tes_inventory, HX_inventory] = find_tbr(I_s_0, I_reserve, t_d_req, TBR_start, model, accuracy, inventory_accuracy)
            TBR = TBR_start;
            assignin("base", "TBR", TBR) % save the value of TBR in the workspace, otherwise Simulink does not read the value computed in the function!
            iteration = 0;
            inner_iteration = 0;
            out = sim(model);
            I_storage = out.I_11;
            td = 10; % Initial value to enter the loop
                while(any(I_storage - I_reserve < 0) || iteration == 0 || t_d >  t_d_req)
                        TBR = TBR + accuracy;
                        assignin("base", "TBR", TBR) % save the value of TBR in the workspace, otherwise Simulink does not read the value computed in the function!
                        assignin("base", "I_s_0", I_s_0)
                        out = sim(model);
                        I_storage = out.I_11;
                        I_bz = out.I_1;
                        I_tes = out.I_2;
                        I_hx = out.I_5;
                        iteration = iteration + 1;
                        disp(iteration)
                        t_d = utilities.doublingTime(I_s_0, out);
                        margin = min(I_storage - I_reserve);
                        blanket_inventory = (max(I_bz)); % kg
                        tes_inventory = (max(I_tes)); % kg
                        HX_inventory = (max(I_hx)); % kg
                    
                        if isempty(t_d)
                            t_d = 20;
                        end 
                            % can be done in one line but this is more
                            % clear: Increase or decrease the startup
                            % inventory according to the margin
                            if margin < 0
                                I_s_0 = I_s_0 + abs(margin) + inventory_accuracy; % add 0.05 to avoid numerical issues
                            else
                                I_s_0 = I_s_0 - abs(margin) + inventory_accuracy;  % add 0.05 to avoid numerical issues
                            end
                        disp("TBR = " + TBR)
                        disp("Doubling time = " + t_d)
                        disp("I_s_0 = " + I_s_0)
                        disp("Minimum difference between storage and reserve " + min(I_storage - I_reserve))
                        disp("Blanket inventory: " + round(max(I_bz)*1000, 2) + " g")
                        disp("TES inventory: " + round(max(I_tes)*1000, 2)  + " g")
                        disp("HX inventory: " + round(max(HX_inventory)*1000, 2)  + " g")
                        if iteration == 1000            
                            iteration = 0;
                            TBR = TBR_start;                            
                            inner_iteration = inner_iteration + 1;
                            disp(inner_iteration)
                        end 
                end
        end
    

        function [TBR, I_s_0, margin, blanket_inventory, tes_inventory, HX_inventory, Div_trapped_inventory, FW_trapped_inventory] = find_tbr_w_trapping(I_s_0, I_reserve, t_d_req, TBR_start, model, accuracy, inventory_accuracy)
            TBR = TBR_start;
            assignin("base", "TBR", TBR) % save the value of TBR in the workspace, otherwise Simulink does not read the value computed in the function!
            iteration = 0;
            inner_iteration = 0;
            out = sim(model);
            I_storage = out.I_11;
            td = 10; % Initial value to enter the loop
                while(any(I_storage - I_reserve < 0) || iteration == 0 || t_d >  t_d_req)
                        TBR = TBR + accuracy
                        assignin("base", "TBR", TBR) % save the value of TBR in the workspace, otherwise Simulink does not read the value computed in the function!
                        assignin("base", "I_s_0", I_s_0)
                        out = sim(model);
                        I_storage = out.I_11;
                        I_bz = out.I_1;
                        I_tes = out.I_2;
                        I_hx = out.I_5;
                        I_fw = out.I_3;
                        iteration = iteration + 1;
                        disp(iteration)
                        t_d = utilities.doublingTime(I_s_0, out);
                        margin = min(I_storage - I_reserve);
                        blanket_inventory = (max(I_bz)); % kg
                        tes_inventory = (max(I_tes)); % kg
                        HX_inventory = (max(I_hx)); % kg
                        FW_inventory = (max(I_fw));
                        bz_trapped_inventory = out.I_1_trapped(end); % kg
                        Div_trapped_inventory = out.I_4_trapped(end); % kg
                        FW_trapped_inventory = out.I_3_trapped(end); %kg
                        if isempty(t_d)
                            t_d = 20;
                        end 
                            % can be done in one line but this is more
                            % clear: Increase or decrease the startup
                            % inventory according to the margin
                            if margin < 0
                                I_s_0 = I_s_0 + abs(margin) + inventory_accuracy; % add 0.05 to avoid numerical issues
                            else
                                I_s_0 = I_s_0 - abs(margin) + inventory_accuracy;  % add 0.05 to avoid numerical issues
                            end
                        disp("TBR = " + TBR)
                        disp("Doubling time = " + t_d)
                        disp("I_s_0 = " + I_s_0)
                        disp("Minimum difference between storage and reserve " + min(I_storage - I_reserve))
                        disp("Blanket inventory: " + round(max(I_bz + bz_trapped_inventory)*1000, 2) + " g")
                        disp("TES inventory: " + round(max(I_tes)*1000, 2)  + " g")
                        disp("HX inventory: " + round(max(HX_inventory)*1000, 2)  + " g")
                        disp("FW/VV inventory: " + round(max(FW_inventory + FW_trapped_inventory)*1000, 2) + " g")


                        if iteration == 1000            
                            iteration = 0;
                            TBR = TBR_start;
                            
                            inner_iteration = inner_iteration + 1;
                            disp(inner_iteration)
                        end 
                end
        end


function td = doublingTime(I_storage_0, simOut)
    t = simOut.tout;
    I_s = simOut.I_11;
    index = find(I_s>2*I_storage_0, 1); % MODIFICA QUA find the first element for which the storage inventory is twice the initial inventoryy
    td = t(index) / 3600 / 24 / 365; % years
    if isempty(td)
        fprintf("\n No doubling time \n")
    end 
end 
    end
end

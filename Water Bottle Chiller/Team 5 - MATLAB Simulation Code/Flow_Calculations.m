clc
clear
close all
warning off
format short g
tic

delete *.xlsx
filename = 'Fluid_data.xlsx';
xlswrite(filename,1,1,'A1')

setup = table(1);
writetable(setup,'Fluid_data.xlsx','Sheet',1,'Range','A1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','First_iter','Range','A1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','iter_pipesize','Range','A1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','iter_flowrate','Range','A1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','pump_spec','Range','A1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','pump_spec','Range','F1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','pump_spec','Range','L1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','pump_spec','Range','R1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','pump_spec','Range','X1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','pump_spec','Range','DD1','WriteVariableNames',true)
writetable(setup,'Fluid_data.xlsx','Sheet','final_design','Range','A1','WriteVariableNames',true)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Conversions                               %
% 1 ft to m
ft_to_m = 0.3048;
% 1 in to m
in_to_m = 0.0254;
% 0 C to K
C_to_K = 273.15;
% 1 gpm to m^3/s
gpm_to_m3s = 0.000063;
% 1 gpH to m^3/s
gph_to_m3s = 0.000001052;
% 1 gallon to m^3
gal_to_m3 = 0.00378541;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                 INPUT                                   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Gravity constant
g = 9.81; % [m^2/s]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Desirable values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pump head target value
lowDesirableHp = 20; % [ft]
highDesirableHp = 30; % [ft]
countHp = 10; % [ft]

% Volumetric flow rate range
lowVdot = 0*gpm_to_m3s; % [m^3/s]
highVdot = 100*gpm_to_m3s; % [m^3/s]
countVdot = 5*gpm_to_m3s; % [m^3/s]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Bottle of water
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dimensions of the bottle
L_bottlebig = 0.15328; % [m]
L_bottletapered = 0.03472; % [m]
L_bottlesmall = 0.017; % [m]
L_bottle = 0.205; % [m]
D_bottle = 63*10^(-3); % [m]
D_bottlehalftapered = D_bottle - 2*L_bottletapered/2*tand(29); % [m]
D_bottlesmalltapered = D_bottle - 2*L_bottletapered*tand(29); % [m]
% Converting the bottle into a cylinder of equal surface area
D_bottle = sqrt(pi/4*(D_bottle^2*L_bottlebig+D_bottlehalftapered^2*...
    L_bottletapered+D_bottlesmalltapered^2*L_bottlesmall)/(L_bottle*pi/4));
V_bottle = L_bottle*pi/4*D_bottle^2; % [m^2]

% Temperature of the bottled water
T_bottle = 20; % [C]

% Range of ambient temperatures
T_bottle_min = 20; % [C]
T_bottle_max = 25; % [C]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Pipe System
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Temperature of the cooling water
T_cw = 0; % [C]

% Thermal properties of the cooling water
% Units are: Pr [], k [W/m.K], rho [kg/m^3], mu [N.s/m^2], P [Pa]
[Pr,k,rho,mu,~,cp] = thermalprop(T_cw+C_to_K);

% Specific weight of the cooling fluid
gamma = rho*g; % [kg/m.s]

% Net positive suction head required. The required minimum pressure to
% avoid cavitation
NPSHR = 0*ft_to_m; % [m]

% Safety factor for the NPSHR
SF = 0*ft_to_m; % [m]

% Volume of water in the bucket
Vol_bucket = 2*gal_to_m3; % [m^3]

% Dimensions and properties of the pipe
D_pipe = 1*in_to_m; % [m]
L_pipe = 13*ft_to_m; % [m]
% Material (n = ):
% 1 = drawn tubing
% 2 = commercial steel or wrought iron
% 3 = asphalted cast iron
% 4 = galvanized iron
% 5 = cast iron
n = 1;
epsilon = rough(n); % [m]

% pressure at the top of the bucket and at the bottom of the bucket,
% assuming a 2 ft deep bucket of water.
h_bucket = 2*ft_to_m; % [m]
P2 = 101000; % [Pa]
P1 = P2+rho*g*h_bucket; % [Pa]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Heat exchanger
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dimensions of the container
nturn = 7;
width_chamber = 1*in_to_m; % [m]
L_chamberlarge = 0.17868; % [m]
L_chambertapered = 0.03472; % [m]
L_chambersmall = 0.0185; % [m]
L_chamber = L_chamberlarge + L_chambertapered + L_chambersmall; % [m]
D_chamber = 0.0884; % [m]
D_chamberhalftapered = D_chamber - 2*L_chambertapered*tand(29); % [m]
D_chambersmalltapered = D_chamber - 2*L_chambertapered*tand(29); % [m]
% Converting the inside chamber into a cylinder of equal surface area
D_chamber = sqrt((pi/4*D_chamber^2*L_chamberlarge+pi/4*...
    D_chamberhalftapered^2*L_chambertapered+pi/4*...
    D_chambersmalltapered^2*L_chambersmall)/(L_chamber*pi/4));
% if widthD_pipe = 0, the width of the chamber sections is fixed to the
% length above, if widthD_pipe = 1, the width of the chamber sections
% depends on the pipe diameter
widthD_pipe = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                Assumptions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Volumetric flow rate delivered by the pump
Vdot_c = 1200*gph_to_m3s; % [m^3/s]
% Saved volumetric flow rate
Vdot_c_used = Vdot_c;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Heat exchanger design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If design = 1, the heat exchanger follows the flow on a cylinder, if
% design = 0, the heat exchanger follows the flow on a flat plate
% If design = 2, the heat exchanger follows the flow in a pipe
% NOTE: The code will return an error if a design other than 2 is chosen
% because design 2 was the one chosen for transient heat transfer 
% calculations. 
Design = 2;

% Number of spirals
nspiral = 6.5;

% Length of the flat plate for the above design choice
L_plate = pi*D_bottle*nspiral; % [m]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Assumptions table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Table to summarize the assumptions and inputs
assump_names = {'Length_bottle';'Diameter_bottle';'height_bucket';...
    'Diameter_chamber';'Length_chamber';'width_chambersections';...
    'L_plate';'Temp_bottle';'Temp_bucket';'rho_bucket';'mu_bucket';...
    'k_bucket';'Pr_bucket';'epsilon_pipe';'Vdot_delivered'};
assump_units = {'m';'m';'m';'m';'m';'m';'m';'C';'C';'kgpm3';'Nspm2';'WpmK';...
    'Dim';'m';'m3ps'};
assump_values = [L_bottle;D_bottle;h_bucket;D_chamber;L_chamber;width_chamber;...
    L_plate;T_bottle;T_cw;rho;mu;k;Pr;epsilon;Vdot_c];
Table_assump = table(assump_names,assump_values,assump_units,'VariableNames',{'Names' 'Value' 'Units'})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                              Solutions                                  %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iteration_count = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   First run, using all assumptions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if widthD_pipe == 1
    width_chamber = D_pipe; % [m]
end
if Design == 1
    [V_c,H_p,Re] = fluidpipe_cylinder(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nturn);
    [V_chamber,Re_chamber] = fluidchamber_cylinder(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,D_pipe);
    [q,h] = heattransfer_cylinder(width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
elseif Design == 0
    [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
    [V_chamber,Re_chamber] = fluidchamber_flatplate(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
    [q,h] = heattransfer_flatplate(L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
elseif Design == 2
    [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
    [V_chamber,Re_chamber] = fluidchamber_pipe(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
    [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
end
Vdot = (V_c*pi*(D_pipe)^2/4)/gpm_to_m3s;
mdot = Vdot*gpm_to_m3s*rho;
Delta_T_cw = q/(cp*mdot);
H = H_p/ft_to_m;
Vol_chamber = L_chamber*D_chamber^2/4*pi;
Vol_pipe = D_pipe^2/4*pi*L_pipe;
Vol_total = Vol_pipe+Vol_chamber;
Percent_Vol_pipe = Vol_total*100/Vol_bucket;

Table_assumptions = table(D_pipe/in_to_m,Vdot,H,Re,V_chamber,Re_chamber,h,q,Delta_T_cw,Percent_Vol_pipe,...
    'VariableNames',{'Pipesize_in' 'Vdot_gpm' 'H_p_ft' 'Re_pipe' 'V_chamber_mps' 'Re_chamber' 'h_Wpm2K' 'q_W' 'Delta_T_movingfluid_HX_C' 'Percent_Volpipe_to_Volbucket'})
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Standard pipe sizes calculation:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inD = [0.006833,0.005461,0.009246,0.007671,0.012522,0.010744,...
    0.015799,0.013868,0.020930,0.018847,0.026645,0.024308,0.035052,...
    0.032461,0.040894,0.038100,0.052502,0.049251,0.062713,...
    0.059004,0.077927,0.073660,0.090119,0.085446];
nomD = {'1/8nom40sch';'1/8nom80sch';'1/4nom40sch';'1/4nom80sch';...
    '3/8nom40sch';'3/8nom80sch';'1/2nom40sch';'1/2nom80sch';...
    '3/4nom40sch';'3/4nom80sch';'1nom40sch';'1nom80sch';...
    '1-1/4nom40sch';'1-1/4nom80sch';'1-1/2nom40sch';'1-1/2nom80sch';...
    '2nom40sch';'2nom80sch';'2-1/2nom40sch';'2-1/2nom80sch';...
    '3nom40sch';'3nom80sch';'3-1/2nom40sch';'3-1/2nom80sch'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Iterative calculations for: Diameter of the pipe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = 1;
for D_pipe = inD
    iteration_count = iteration_count + 1;
    if widthD_pipe == 1
        width_chamber = D_pipe; % [m]
    end
    if Design == 1
        [V_c,H_p,Re] = fluidpipe_cylinder(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nturn);
        [V_chamber,Re_chamber] = fluidchamber_cylinder(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,D_pipe);
        [q,h] = heattransfer_cylinder(width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
    elseif Design == 0
        [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
        [V_chamber,Re_chamber] = fluidchamber_flatplate(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
        [q,h] = heattransfer_flatplate(L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
    elseif Design == 2
        [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
        [V_chamber,Re_chamber] = fluidchamber_pipe(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
        [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
    end
    Vdot = (V_c*pi*(D_pipe)^2/4)/gpm_to_m3s;
    mdot = Vdot*gpm_to_m3s*rho;
    Delta_T_cw = q/(cp*mdot);
    
    Vol_chamber = L_chamber*D_chamber^2/4*pi;
    Vol_pipe = D_pipe^2/4*pi*L_pipe;
    Vol_total = Vol_pipe+Vol_chamber;
    Percent_Vol_pipe = Vol_total*100/Vol_bucket;
    
    h_total(i) = h;
    q_total(i) = q;
    V_chamber_total(i) = V_chamber;
    Re_chamber_total(i) = Re_chamber;
    Vdot_c_total(i) = Vdot;
    H_p_total(i) = H_p/ft_to_m;
    Re_total(i) = Re;
    T_fluid_out_total(i) = Delta_T_cw;
    Percent_Vol_pipe_total(i) = Percent_Vol_pipe;
    i = i + 1;
end
Vdot_t = Vdot_c_total(:);
H = H_p_total(:);
Re_t = Re_total(:);
q_t = q_total(:);
h_t = h_total(:);
V_chamber_t = V_chamber_total(:);
Re_chamber_t = Re_chamber_total(:);
T_fluid_out_t = T_fluid_out_total(:);
Percent_Vol_pipe_t = Percent_Vol_pipe_total(:);
Table_pipesize = table(nomD,Vdot_t,H,Re_t,V_chamber_t,Re_chamber_t,h_t,q_t,T_fluid_out_t,Percent_Vol_pipe_t,...
    'VariableNames',{'StandardSize' 'Vdot_gpm' 'H_p_ft' 'Re_pipe' 'V_chamber_mps' 'Re_chamber' 'h_Wpm2K' 'q_W' 'Delta_T_movingfluid_HX_C' 'Percent_Volpipe_to_Volbucket'})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Saving most desirable Diameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

H2 = H(H < highDesirableHp & H > lowDesirableHp);
for i = 1:length(H2)
    [c,index] = min(abs(H - H2(i)));
    inD2(i) = inD(index);
    nomD2(i) = nomD(index);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Iterative calculations for: Volumetric flow rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear Vdot_c_total
clear H_p_total
clear Re_total
clear V_chamber_total
clear Re_chamber_total
clear h_total
clear q_total
clear T_fluid_out_total
clear Percent_Vol_pipe_total
jj = 1;
for j = 1:length(inD2)
    Vdot_iter = lowVdot:countVdot:highVdot;
    D_pipe = inD2(j);
    i = 1;
    for Vdot_c = Vdot_iter(2:length(Vdot_iter))
        iteration_count = iteration_count + 1;
        if widthD_pipe == 1
            width_chamber = D_pipe; % [m]
        end
        if Design == 1
            [V_c,H_p,Re] = fluidpipe_cylinder(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nturn);
            [V_chamber,Re_chamber] = fluidchamber_cylinder(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,D_pipe);
            [q,h] = heattransfer_cylinder(width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
        elseif Design == 0
            [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
            [V_chamber,Re_chamber] = fluidchamber_flatplate(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
            [q,h] = heattransfer_flatplate(L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
        elseif Design == 2
            [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
            [V_chamber,Re_chamber] = fluidchamber_pipe(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
            [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
        end
        Vdot = (V_c*pi*(D_pipe)^2/4)/gpm_to_m3s;
        mdot = Vdot*gpm_to_m3s*rho;
        Delta_T_cw = q/(cp*mdot);
        
        Vol_chamber = L_chamber*D_chamber^2/4*pi;
        Vol_pipe = D_pipe^2/4*pi*L_pipe;
        Vol_total = Vol_pipe+Vol_chamber;
        Percent_Vol_pipe = Vol_total*100/Vol_bucket;
        
        q_total(i) = q;
        h_total(i) = h;
        V_chamber_total(i) = V_chamber;
        Re_chamber_total(i) = Re_chamber;
        Vdot_c_total(i) = Vdot;
        H_p_total(i) = H_p/ft_to_m;
        Re_total(i) = Re;
        T_fluid_out_total(i) = Delta_T_cw;
        Percent_Vol_pipe_total(i) = Percent_Vol_pipe;
        i = i + 1;
    end
    Vdot_t = Vdot_c_total';
    H = H_p_total';
    Re_t = Re_total';
    V_chamber_t = V_chamber_total';
    Re_chamber_t = Re_chamber_total';
    h_t = h_total';
    q_t = q_total';
    T_fluid_out_t = T_fluid_out_total';
    Percent_Vol_pipe_t = Percent_Vol_pipe_total';
    
    [nomD3{1:length(Vdot_t)}] = deal(nomD2(j));
    nomD3 = table2array(cell2table(nomD3'));
    [empty{1:length(Vdot_t)}] = deal('||');
    empty = table2array(cell2table(empty'));
    Table_Vdot(:,jj) = empty;
    Table_Vdot(:,jj+1) = nomD3;
    Table_Vdot(:,jj+2) = num2cell(Vdot_t);
    Table_Vdot(:,jj+3) = num2cell(H);
    Table_Vdot(:,jj+4) = num2cell(Re_t);
    Table_Vdot(:,jj+5) = num2cell(V_chamber_t);
    Table_Vdot(:,jj+6) = num2cell(Re_chamber_t);
    Table_Vdot(:,jj+7) = num2cell(h_t);
    Table_Vdot(:,jj+8) = num2cell(q_t);
    Table_Vdot(:,jj+9) = num2cell(T_fluid_out_t);
    Table_Vdot(:,jj+10) = num2cell(Percent_Vol_pipe_t);
    
    Table_Vdotname(jj) = {['Case_' num2str(j)]};
    Table_Vdotname(jj+1) = {['StandardSize_' num2str(j)]};
    Table_Vdotname(jj+2) = {['Vdot_gpm_' num2str(j)]};
    Table_Vdotname(jj+3) = {['H_p_ft_' num2str(j)]};
    Table_Vdotname(jj+4) = {['Re_pipe_' num2str(j)]};
    Table_Vdotname(jj+5) = {['V_chamber_mps_' num2str(j)]};
    Table_Vdotname(jj+6) = {['Re_chamber_' num2str(j)]};
    Table_Vdotname(jj+7) = {['h_Wpm2K_' num2str(j)]};
    Table_Vdotname(jj+8) = {['q_W_' num2str(j)]};
    Table_Vdotname(jj+9) = {['Delta_T_movingfluid_HX_C_' num2str(j)]};
    Table_Vdotname(jj+10) = {['Percent_Volpipe_to_Volbucket_' num2str(j)]};
    
    jj = jj + 11;
end
Table_Vdot = cell2table(Table_Vdot,'VariableNames',Table_Vdotname)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Transient heat transfer for chosen dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:height(Table_Vdot)
    [c,index] = min(abs(table2array(Table_Vdot(:,3)) - Vdot_c_used/gpm_to_m3s));
    Vdot_c = table2array(Table_Vdot(index,3))'*gpm_to_m3s;
end

clear Vdot_c_total
clear H_p_total
clear Re_total
clear V_chamber_total
clear Re_chamber_total
clear h_total
clear q_total
clear T_fluid_out_total
clear Percent_Vol_pipe_total
clear nomD3
clear empty

jj = 1;
for j = 1:length(inD2)
    D_pipe = inD2(j);
    i = 1;
    z = 1;
    T_bottle_run = T_bottle_max:-1:T_bottle_min;
    for T_bottle = T_bottle_run
        iteration_count = iteration_count + 1;
        if widthD_pipe == 1
            width_chamber = D_pipe; % [m]
        end
        if Design == 1
            [V_c,H_p,Re] = fluidpipe_cylinder(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nturn);
            [V_chamber,Re_chamber] = fluidchamber_cylinder(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,D_pipe);
            [q,h] = heattransfer_cylinder(width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
        elseif Design == 0
            [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
            [V_chamber,Re_chamber] = fluidchamber_flatplate(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
            [q,h] = heattransfer_flatplate(L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
        elseif Design == 2
            [V_c,H_p,Re,f_t] = fluidpipe_flatplate(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nspiral,width_chamber,D_chamber,D_bottle);
            [V_chamber,Re_chamber] = fluidchamber_pipe(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe);
            [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle);
        end
        Vdot = (V_c*pi*(D_pipe)^2/4)/gpm_to_m3s;
        mdot = Vdot*gpm_to_m3s*rho;
        Delta_T_cw = q/(cp*mdot);
        
        Vol_chamber = L_chamber*D_chamber^2/4*pi;
        Vol_pipe = D_pipe^2/4*pi*L_pipe;
        Vol_total = Vol_pipe+Vol_chamber;
        Percent_Vol_pipe = Vol_total*100/Vol_bucket;
        
        [time_total1,temperature1,time_total2,temperature2] = Transient(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,h,T_bottle,T_bottle_max,10);
        
        maxtime = [max(time_total1),max(time_total2)];
        mintime = [min(time_total1),min(time_total2)];
        maxtemp = [max(temperature1),max(temperature2)];
        mintemp = [min(temperature1),min(temperature2)];
        yplottick = zeros(1,10);
        intertemp = ((300-max(time_total2(time_total2<max(time_total2,[],'omitnan')),[],'omitnan'))*...
            (min(temperature2,[],'omitnan')-...
            min(temperature2(temperature2>min(temperature2,[],'omitnan')),[],'omitnan')))/...
            (max(time_total2,[],'omitnan')-...
            max(time_total2(time_total2<max(time_total2,[],'omitnan')),[],'omitnan'))+...
            min(temperature2(temperature2>min(temperature2,[],'omitnan')),[],'omitnan');
        yplottick(2:length(yplottick)) = linspace(intertemp,max(maxtemp),length(yplottick)-1);
        
        count_plot = length(T_bottle_run);
        xwidth = 1000;
        ywidth = 1000;
        hfig = figure(j);
        set(hfig,'Position', [500 0 xwidth ywidth]);
        subplot(ceil(sqrt(count_plot)),ceil(sqrt(count_plot)),i)
        plot(time_total1,temperature1,time_total2,temperature2,time_total2,ones(1,length(temperature2))*intertemp,'--')
        xticks(linspace(0,max(maxtime),5));
        xtickformat('%,.1f')
        yticks(yplottick);
        axis([0 max(maxtime) 0 max(maxtemp)]);
        title(['Ambient Temperature of ' num2str(T_bottle) 'C'])
        xlabel('time (s)')
        ylabel('Temperature (C)')
        grid on
        
        [nomD3{1:length(temperature2)}] = deal(nomD2(j));
        nomD3 = table2array(cell2table(nomD3'));
        [empty{1:length(temperature2)}] = deal('||');
        empty = table2array(cell2table(empty'));
        Table_Transient(:,z) = empty;
        Table_Transient(:,z+1) = num2cell(time_total1);
        Table_Transient(:,z+2) = num2cell(time_total2);
        Table_Transient(:,z+3) = num2cell(temperature2);
        
        Table_Transient_name(z) = {['Ambient_T_of_' num2str(T_bottle) '_C']};
        Table_Transient_name(z+1) = {['Cooling_time_radius_s_for_' num2str(T_bottle) '_C']};
        Table_Transient_name(z+2) = {['Cooling_time_center_s_for_' num2str(T_bottle) '_C']};
        Table_Transient_name(z+3) = {['Temperature_drop_C_for_' num2str(T_bottle) '_C']};
        
        T_bottle_total(i) = T_bottle;
        q_total(i) = q;
        h_total(i) = h;
        V_chamber_total(i) = V_chamber;
        Re_chamber_total(i) = Re_chamber;
        Vdot_c_total(i) = Vdot;
        H_p_total(i) = H_p/ft_to_m;
        Re_total(i) = Re;
        T_fluid_out_total(i) = Delta_T_cw;
        Percent_Vol_pipe_total(i) = Percent_Vol_pipe;
        z = z + 4;
        i = i + 1;
    end
    clear nomD3
    clear empty
    Table_Transient_total = cell2table(Table_Transient,'VariableNames',Table_Transient_name)
    writetable(Table_Transient_total,'Fluid_data.xlsx','Sheet',['Transient_analysis' num2str(j)],'Range','A1','WriteVariableNames',true)
    
    T_bottle_t = T_bottle_total';
    Vdot_t = Vdot_c_total';
    H = H_p_total';
    Re_t = Re_total';
    V_chamber_t = V_chamber_total';
    Re_chamber_t = Re_chamber_total';
    h_t = h_total';
    q_t = q_total';
    T_fluid_out_t = T_fluid_out_total';
    Percent_Vol_pipe_t = Percent_Vol_pipe_total';
    
    [nomD3{1:length(T_bottle_run)}] = deal(nomD2(j));
    nomD3 = table2array(cell2table(nomD3'));
    [empty{1:length(T_bottle_run)}] = deal('||');
    empty = table2array(cell2table(empty'));
    Table_Vdot2(:,jj) = empty;
    Table_Vdot2(:,jj+1) = nomD3;
    Table_Vdot2(:,jj+2) = num2cell(T_bottle_t);
    Table_Vdot2(:,jj+3) = num2cell(Vdot_t);
    Table_Vdot2(:,jj+4) = num2cell(H);
    Table_Vdot2(:,jj+5) = num2cell(Re_t);
    Table_Vdot2(:,jj+6) = num2cell(V_chamber_t);
    Table_Vdot2(:,jj+7) = num2cell(Re_chamber_t);
    Table_Vdot2(:,jj+8) = num2cell(h_t);
    Table_Vdot2(:,jj+9) = num2cell(q_t);
    Table_Vdot2(:,jj+10) = num2cell(T_fluid_out_t);
    Table_Vdot2(:,jj+11) = num2cell(Percent_Vol_pipe_t);
    
    Table_Vdotname2(jj) = {['Case_' num2str(j)]};
    Table_Vdotname2(jj+1) = {['StandardSize_' num2str(j)]};
    Table_Vdotname2(jj+2) = {['Inital_T_bottle_C_' num2str(j)]};
    Table_Vdotname2(jj+3) = {['Vdot_gpm_' num2str(j)]};
    Table_Vdotname2(jj+4) = {['H_p_ft_' num2str(j)]};
    Table_Vdotname2(jj+5) = {['Re_pipe_' num2str(j)]};
    Table_Vdotname2(jj+6) = {['V_chamber_mps_' num2str(j)]};
    Table_Vdotname2(jj+7) = {['Re_chamber_' num2str(j)]};
    Table_Vdotname2(jj+8) = {['h_Wpm2K_' num2str(j)]};
    Table_Vdotname2(jj+9) = {['q_W_' num2str(j)]};
    Table_Vdotname2(jj+10) = {['Delta_T_movingfluid_HX_C_' num2str(j)]};
    Table_Vdotname2(jj+11) = {['Percent_Volpipe_to_Volbucket_' num2str(j)]};
    
    jj = jj + 12;
    jold = j;
end
Table_Vdot_final = cell2table(Table_Vdot2,'VariableNames',Table_Vdotname2)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Pump chosen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = 5;
count = 20;
% First pump choice: https://www.waterpumpsdirect.com/manuals/EEAUP250_Spec.pdf
maxflow = 3000;
maxhead = 18;
xwidth = 1000;
ywidth = 1000;
hfig = figure(jold+1);
set(hfig,'Position', [500 0 xwidth ywidth]);
subplot(ceil(sqrt(n)),ceil(sqrt(n)),1)
[pumpspec1,x,eq1] = plot_pump(maxflow,maxhead,count);
plot(x,eq1)
xticks(linspace(0,maxflow,5));
yticks(linspace(0,maxhead,5));
axis([0 maxflow 0 maxhead]);
title('Wayne RUP160 ($126.99)')
xlabel('Volumetric Flow rate (GPH)')
ylabel('Head (ft)')
grid on
[name1{1:height(pumpspec1)}] = deal('||'); name1 = table2array(cell2table(name1'));name1(1) = {'Wayne RUP160 ($126.99)'};
pump1 = table(name1,table2array(pumpspec1(:,1)),table2array(pumpspec1(:,2)),table2array(pumpspec1(:,3)),'VariableNames',{'Pump' 'ft' 'GPM' 'GPH'})

% Second pump choice: https://www.waterpumpsdirect.com/manuals/New2385_Spec.pdf
maxflow = 3000;
maxhead = 20;
subplot(ceil(sqrt(n)),ceil(sqrt(n)),2)
[pumpspec2,x,eq1] = plot_pump(maxflow,maxhead,count);
plot(x,eq1)
xticks(linspace(0,maxflow,5));
yticks(linspace(0,maxhead,5));
axis([0 maxflow 0 maxhead]);
title('Simer 2385 ($99.99)')
xlabel('Volumetric Flow rate (GPH)')
ylabel('Head (ft)')
grid on
[name2{1:height(pumpspec2)}] = deal('||'); name2 = table2array(cell2table(name2'));name2(1) = {'Simer 2385 ($99.99)'};
pump2 = table(name2,table2array(pumpspec2(:,1)),table2array(pumpspec2(:,2)),table2array(pumpspec2(:,3)),'VariableNames',{'Pump' 'ft' 'GPM' 'GPH'})

% Third pump choice: https://www.waterpumpsdirect.com/manuals/flotec-41abcdbea43813a491e29bcb7dafed7a.pdf
maxflow = 3000;
maxhead = 25;
subplot(ceil(sqrt(n)),ceil(sqrt(n)),3)
[pumpspec3,x,eq1] = plot_pump(maxflow,maxhead,count);
plot(x,eq1)
xticks(linspace(0,maxflow,5));
yticks(linspace(0,maxhead,5));
axis([0 maxflow 0 maxhead]);
title('Flotec FP0S3000X ($115)')
xlabel('Volumetric Flow rate (GPH)')
ylabel('Head (ft)')
grid on
[name3{1:height(pumpspec3)}] = deal('||'); name3 = table2array(cell2table(name3'));name3(1) = {'Flotec FP0S3000X ($115)'};
pump3 = table(name3,table2array(pumpspec3(:,1)),table2array(pumpspec3(:,2)),table2array(pumpspec3(:,3)),'VariableNames',{'Pump' 'ft' 'GPM' 'GPH'})

% Fourth pump choice: http://www.harborfreight.com/lawn-garden/pumps/14-hp-submersible-sump-pump-with-vertical-float-2800-gph-68455.html
maxflow = 2800;
maxhead = 22;
subplot(ceil(sqrt(n)),ceil(sqrt(n)),4)
[pumpspec4,x,eq1] = plot_pump(maxflow,maxhead,count);
plot(x,eq1)
xticks(linspace(0,maxflow,5));
yticks(linspace(0,maxhead,5));
axis([0 maxflow 0 maxhead]);
title('Pacific Hydrostar SKU68455 ($35)')
xlabel('Volumetric Flow rate (GPH)')
ylabel('Head (ft)')
grid on
[name4{1:height(pumpspec4)}] = deal('||'); name4 = table2array(cell2table(name4'));name4(1) = {'Pacific Hydrostar SKU68455 ($35)'};
pump4 = table(name4,table2array(pumpspec4(:,1)),table2array(pumpspec4(:,2)),table2array(pumpspec4(:,3)),'VariableNames',{'Pump' 'ft' 'GPM' 'GPH'})

% Fifth pump choice: http://www.harborfreight.com/lawn-garden/pumps/12-hp-submersible-sump-pump-with-vertical-float-3200-gph-68454.html
maxflow = 3200;
maxhead = 28;
subplot(ceil(sqrt(n)),ceil(sqrt(n)),5)
[pumpspec5,x,eq1] = plot_pump(maxflow,maxhead,count);
plot(x,eq1)
xticks(linspace(0,maxflow,5));
yticks(linspace(0,maxhead,5));
axis([0 maxflow 0 maxhead]);
title('Pacific Hydrostar SKU68454 ($50)')
xlabel('Volumetric Flow rate (GPH)')
ylabel('Head (ft)')
grid on
[name5{1:height(pumpspec5)}] = deal('||'); name5 = table2array(cell2table(name5'));name5(1) = {'Pacific Hydrostar SKU68454 ($50)'};
pump5 = table(name5,table2array(pumpspec5(:,1)),table2array(pumpspec5(:,2)),table2array(pumpspec5(:,3)),'VariableNames',{'Pump' 'ft' 'GPM' 'GPH'})

% Sixth pump choice: http://www.homedepot.com/p/Everbilt-1-3-HP-Pedestal-Sump-Pump-SCN250-LQ/205617276
maxflow = 3550;
maxhead = 30;
subplot(ceil(sqrt(n)),ceil(sqrt(n)),5)
[pumpspec6,x,eq1] = plot_pump(maxflow,maxhead,count);
plot(x,eq1)
xticks(linspace(0,maxflow,5));
yticks(linspace(0,maxhead,5));
axis([0 maxflow 0 maxhead]);
title('Everbuilt Pedestal sump pump ($77)')
xlabel('Volumetric Flow rate (GPH)')
ylabel('Head (ft)')
grid on
[name6{1:height(pumpspec6)}] = deal('||'); name6 = table2array(cell2table(name6'));name6(1) = {'Everbuilt Pedestal sump pump ($77)'};
pump6 = table(name6,table2array(pumpspec6(:,1)),table2array(pumpspec6(:,2)),table2array(pumpspec6(:,3)),'VariableNames',{'Pump' 'ft' 'GPM' 'GPH'})

writetable(Table_assump,'Fluid_data.xlsx','Sheet',1,'Range','A1','WriteVariableNames',true)
writetable(Table_assumptions,'Fluid_data.xlsx','Sheet','First_iter','Range','A1','WriteVariableNames',true)
writetable(Table_pipesize,'Fluid_data.xlsx','Sheet','iter_pipesize','Range','A1','WriteVariableNames',true)
writetable(Table_Vdot,'Fluid_data.xlsx','Sheet','iter_flowrate','Range','A1','WriteVariableNames',true)
writetable(pump1,'Fluid_data.xlsx','Sheet','pump_spec','Range','A1','WriteVariableNames',true)
writetable(pump2,'Fluid_data.xlsx','Sheet','pump_spec','Range','F1','WriteVariableNames',true)
writetable(pump3,'Fluid_data.xlsx','Sheet','pump_spec','Range','L1','WriteVariableNames',true)
writetable(pump4,'Fluid_data.xlsx','Sheet','pump_spec','Range','R1','WriteVariableNames',true)
writetable(pump5,'Fluid_data.xlsx','Sheet','pump_spec','Range','X1','WriteVariableNames',true)
writetable(pump6,'Fluid_data.xlsx','Sheet','pump_spec','Range','AC1','WriteVariableNames',true)
writetable(Table_Vdot_final,'Fluid_data.xlsx','Sheet','final_design','Range','A1','WriteVariableNames',true)

iteration_count
toc


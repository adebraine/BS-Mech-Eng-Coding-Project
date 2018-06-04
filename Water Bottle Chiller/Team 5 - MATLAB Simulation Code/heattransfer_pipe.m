function [q,h] = heattransfer_pipe(f_t,L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle)
A_chamber_flow = width_chamber*(D_chamber-D_bottle)/2;
[Pr,k,rho,mu,~,~] = thermalprop(T_cw+C_to_K);
D_thermal = width_chamber;

syms Re D_h Reinf
eq1 = Re == rho*V_chamber*D_thermal/mu;
eq2 = D_h == 4*A_chamber_flow/(2*width_chamber+(D_chamber-D_bottle));
s1 = solve(eq1,eq2);
Re = eval(s1.Re);
D_h = eval(s1.D_h);

if Re<=2300
%     disp('case 1')
    if 0.05*Re*Pr*D_h < L_plate
        ratio_cross_section = width_chamber/((D_chamber-D_bottle)/2);
        if ratio_cross_section >= 1 && ratio_cross_section < 1.43
            Nu_D = 2.98;
        elseif ratio_cross_section >= 1.43 && ratio_cross_section < 2.0
            Nu_D = 3.08;
        elseif ratio_cross_section >= 2.0 && ratio_cross_section < 3.0
            Nu_D = 3.39;
        elseif ratio_cross_section >= 3.0 && ratio_cross_section < 4.0
            Nu_D = 3.96;
        elseif ratio_cross_section >= 4.0 && ratio_cross_section < 8.0
            Nu_D = 4.44;
        elseif ratio_cross_section >= 8.0
            Nu_D = 5.6;
        end
    else
        GzD = (D_h/L_plate)*Re*Pr;
        Nu_D = ((3.66/(tanh(2.264*GzD^(-1/3)+1.7*GzD^(-2/3)))+0.0499*...
            GzD*tanh(GzD^(-1)))/(tanh(2.432*Pr^(1/6)*GzD^(-1/6))));
    end
elseif Re > 2300
%     disp('case 2')
    Nu_D = ((f_t/8)*(Re-1000)*Pr)/(1+12.7*((f_t/8)^0.5)*(Pr^(2/3)-1));
    if L_plate/D_thermal < 60
        Nu_D = (1+1/(L_plate/D_thermal)^(2/3))*Nu_D;
    end   
end
    syms h q
    eq1 = Nu_D == h*D_thermal/k;
    eq2 = q == h*L_bottle*pi*D_bottle*(T_bottle-T_cw);
    
    s = solve(eq1,eq2);
    q = eval(s.q);
    h = eval(s.h);
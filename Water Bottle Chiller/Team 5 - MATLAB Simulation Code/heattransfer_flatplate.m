function [q,h] = heattransfer_flatplate(L_plate,width_chamber,V_chamber,D_chamber,D_bottle,L_bottle,T_cw,C_to_K,T_bottle)
A_chamber_flow = width_chamber*(D_chamber-D_bottle)/2;
[Pr,k,rho,mu,~,~] = thermalprop((T_cw+C_to_K+T_bottle+C_to_K)/2);

syms Re D_h Reinf
eq1 = Re == rho*V_chamber*L_plate/mu;
eq2 = D_h == 4*A_chamber_flow/(2*width_chamber+(D_chamber-D_bottle));
s1 = solve(eq1,eq2);
Re = eval(s1.Re);
D_h = eval(s1.D_h);

if Re<=5*10^5 && Pr>=0.6
%     disp('case 1')
    Nu_D = 0.664*Re^(1/2)*Pr^(1/3);
    syms h q
    eq1 = Nu_D == h*L_plate/k;
    eq2 = q == h*L_bottle*pi*D_bottle*(T_bottle-T_cw);
    
    s = solve(eq1,eq2);
    q = eval(s.q);
    h = eval(s.h);
elseif Re > 5*10^5 && Re <= 10^8 && Pr>=0.6 && Pr<=60
%     disp('case 2')
    Nu_D = (0.037*Re^(4/5)-871)*Pr^(1/3);
    syms h q
    eq1 = Nu_D == h*L_plate/k;
    eq2 = q == h*L_bottle*pi*D_bottle*(T_bottle-T_cw);
    
    s = solve(eq1,eq2);
    q = eval(s.q);
    h = eval(s.h);
end




function [V_chamber,Re] = fluidchamber_pipe(width_chamber,rho,mu,Vdot_c,D_chamber,D_bottle,L_plate,D_pipe)
A_pipe = pi*D_pipe^2/4;
A_chamber_flow = width_chamber*(D_chamber-D_bottle)/2;

syms V_c V_chamber Re D_h
eq1 = Vdot_c == V_chamber*A_chamber_flow;
eq2 = Re == rho*V_chamber*D_h/mu;
eq3 = D_h == 4*A_chamber_flow/(2*width_chamber+(D_chamber-D_bottle));

s = solve(eq1,eq2,eq3);

V_chamber = eval(s.V_chamber);
Re = eval(s.Re);

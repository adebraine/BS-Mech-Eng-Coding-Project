function [V_c,H_p,Re] = fluidpipe_cylinder(D_pipe,P2,P1,h_bucket,L_pipe,g,NPSHR,SF,gamma,epsilon,rho,mu,Vdot_c,nturn)
A_pipe = pi*D_pipe^2/4;
DeltaP = P2-P1;
DeltaZ = h_bucket;
K_ent = 0.5;
K_ext = 1;
coef_elbow_general = elbowcoef(1);
coef_elbow_chamber = 50;

syms f V_c H_p sumK Re K_elbow K_returnbend

eq1 = H_p == (f*L_pipe/D_pipe+sumK)*(V_c^2/(2*g))+(NPSHR+SF)+DeltaZ+DeltaP/gamma;
eq2 = f == 0.25*log10((epsilon/D_pipe)/3.7+5.74/Re^0.9)^(-2);
eq3 = Re == rho*V_c*D_pipe/mu;
eq4 = sumK == K_ent + K_ext + 2*K_elbow + nturn*K_returnbend;
eq5 = K_elbow == coef_elbow_general*f;
eq6 = K_returnbend == coef_elbow_chamber*f;
eq7 = V_c == Vdot_c/A_pipe;

s = solve(eq1,eq2,eq3,eq4,eq5,eq6,eq7);

V_c = eval(s.V_c);
H_p = eval(s.H_p);
Re = eval(s.Re);


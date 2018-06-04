% Project 1
clc
clear
warning off
close all


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%                                Inputs                                  %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data table: Step between values reported. 
% Reported values = values every nth step
% where nth = "timerstep"
timerstep = 50;

% size of the figures
xwidth = 1400; % [pixels]
ywidth = 300; % [pixels]

% Air viscosity
mu = 1.85e-5; % [Pa.s]

% Particle density
rhop = 1000; % [kg/m^3]

% Particle diameter
dp = 10e-6; % [m]

% Particle relaxation time
tau = dp^2*rhop/(mu*18); % [s]

% Velocity at pleat entrance
Ui = 1; % [m/s]

% Pleat length
l = 0.0275; % [m]

% Pleat Height
h = 0.0011; % [m]

% Vertical positions of the particles
ypi = [0.05*h 0.25*h 0.5*h 0.75*h 0.95*h]; % [m]

% step time in the interval
step = 0.00001; % [s]

% Expected array size (obtained by trial and error, attempt at maximizing
% speed)
arraysize = 10;
array = zeros(arraysize,1);

% Starting time
t0 = 0; % [s]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%                            Calculations                                %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Average velocity inside the pleat channel in the x-direction in terms of
% x
uaverage =@(x) Ui*(1-x./(l+h)); % [m/s]

% Velocity inside the pleat channel in the y-direction
vh =@(h) Ui*(h/(l+h)); % [m/s]

% Air velocity in the pleat channel x-direction in terms of x and y
u =@(x,y) 3/2*uaverage(x).*(1-(y/h).^2); % [m/s]

% Air velocity in the pleat channel y-direction in terms of x and y
v =@(x,y) vh(h).*sin(pi/2*y/h); % [m/s]

% Stokes number
St = (tau*Ui)/(2*h);

% Angle with repsect to the axial direction by which a poarticle enters the
% pleat channel
alphai = 75*(0.78*(ypi/h).^2+0.16*ypi/h)*exp((-1.61)*St); % [rad]

% Setting up the differential equations
f1x =@(t,x,x2,y,y2) x2;
f1y =@(t,x,x2,y,y2) y2;
f2x =@(t,x,x2,y,y2) -1/tau*x2+1/tau*u(x,y);
f2y =@(t,x,x2,y,y2) -1/tau*y2+1/tau*v(x,y);

% Preallocating the output values for speed
xpall = zeros(arraysize);
ypall = zeros(arraysize);

% Setting up a loop that will perform the runge-kutta calculations for each
% desired outcome, in other words for each particle released. From the
% first term of ypi to the last term of ypi
% for i = 1 -> 5
for i = 1:length(ypi)
    % Initial conditions:
    x10 =0;
    x20 = Ui*cosd(alphai(i));
    y10 = ypi(i);
    y20 = -Ui*sind(alphai(i));
    
    % Runge-Kutta 4th for 2nd order ODE
    [xp,yp] = RK4(f1x,f2x,f1y,f2y,t0,x10,x20,y10,y20,step,l,h,array);
    
    % Eliminating the extra 0 values due to the preallocation of the array
    xp = xp(xp~=0);
    yp = yp(1:length(xp));
    
    % Putting all xp values within one array and all yp values within one
    % array, which corresponds to the number of particles at each position
    for Q = 1:length(xp)
        xpall(Q,i) = xp(Q);
        ypall(Q,i) = yp(Q);
    end


    
    % Graphing the travel path of each particles from l/2 to l
    
    % Setting the size of the figure
    fig = 1;
    figure (fig)
    hFig = figure(fig);
    set(hFig, 'Position', [100 500 xwidth ywidth])
    axis([0 l 0 h])
    
    plot(xp,yp,'LineWidth',4)
    xlabel('x-position (m)')
    ylabel('y-position (m)')   
    title('Five Particles travel paths')
    legend('1st Particle','2nd Particle','3rd Particle','4th Particle',...
        '5th Particle')
    % Hold all will cycle through the default color patterns for each
    % graphs
    hold all
end



% define title
prob_title = 'project 1: particle trajectory in pleated filters';
upper_pt = upper(prob_title); % convert to upper case
fprintf('   %s     \n\n',upper_pt);

% Printing output
fprintf('\n\n')
fprintf('values displayed every %4.2f instances of %4.6f s \n',timerstep...
    ,step)
fprintf('  time(s)   |     1st particle      |')
fprintf('     2nd particle      |     3rd particle      ')
fprintf('|     4th particle      |     ')
fprintf('5th particle      |\n')

fprintf('            | x-pos (m) | y-pos (m) |')
fprintf(' x-pos (m) | y-pos (m) | x-pos (m) | y-pos (m) ')
fprintf('| x-pos (m) | y-pos (m) | x-pos (m) | y-pos (m) |\n')

% Setting up a loop that will print outputs in the following order
% each column first for each row
timer = 0;
for oo = 1:timerstep:length(xpall)
    
    fprintf(' %4.5f =  |',timer)
    for pp = 1:length(ypi)
        fprintf('  %4.5f  |  %4.5f  |',xpall(oo,pp),ypall(oo,pp))
    end
    fprintf('\n')
    
    % Setting the output interval: which is needed to avoid a too large
    % table
    timer = timer +step*timerstep;
end




% stop conditions: xp > l or yp > h

% 1. Runge Kutta 4th order
% 2. 5 particle trajectories in one graph
% 3. table with 11 columns (1 for time, 2 for x and y for each particle)
% 4. Write a report



















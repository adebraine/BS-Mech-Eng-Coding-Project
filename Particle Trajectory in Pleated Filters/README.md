
# PARTICLE TRAJECTORY IN PLEATED FILTERS

**Prepared by: Arnaud Debraine**

**Virginia Commonwealth University - Department of Mechanical Engineering**

**EGMN 321-002 - Numerical Methods**


# Contents

- 1 Introduction
   - 1.1 Summary
   - 1.2 Project Statement
- 2 Methodology
   - 2.1 Analysis
   - 2.2 Code description
- 3 Conclusions
   - 3.1 Results
- 4 Appendices
   - 4.1 Appendix A - References
   - 4.2 Appendix B - Formulas
   - 4.3 Appendix C - Output
   - 4.4 Appendix D - Input Code


# 1. Introduction

## 1.1 Summary

Air filters serve many purposes like removing unwanted particles and
cleaning the air as it comes through an air conditioning unit or a car
engine. It is important to understand the properties of air filters in
order to improve performance and increase its range of application. The
purpose of the project was to model the travel path of particles through
an air filter through the use of numerical computation.

## 1.2 Project Statement

In this project, aerosol particles traveled through half a pleat channel
as it was assumed to be symmetrical along the horizontal axis for
simplicity. The model was also geometrically simplified by considering
the pleat channel as having a rectangular shaped xy plane cross-section.
To calculate the position of a particle as it travels through the pleat
channel, the numerical 4th Runge-Kutta method was used. Five particles
entering the pleat channel at different heights were considered. The
expected outcome was a parabolic travel path for each particle.

# 2. Methodology

## 2.1 Analysis

In order to simulate the travel path of a particle through a pleat
channel, the following two second order ODEs were given. 

$\frac{d^2 x_p}{d t^2}+\frac{1}{\tau}\frac{d x_p}{dt}=\frac{1}{\tau} u(x,y)$

$\frac{d^2 y_p}{d t^2}+\frac{1}{\tau}\frac{d y_p}{dt}=\frac{1}{\tau} v(x,y)$

with:\
$u(x,y) = \frac{3}{2} \bar{u}(x)[1-(\frac{y}{h})^2]$\
$\bar{u}(x) = U_i(1-\frac{x}{l+h})$\
\
$v(x,y) = v(h) sin(\frac{\pi}{2} \frac{y}{h})$\
$v(h) = U_i(\frac{h}{l+h})$\


The two second order ODEs were split in two first order ODEs each using
the method described in **Figure 4.1**. The four resulting
ODEs were solved simultaneously using MATLAB. The final 4th Runge-Kutta
computational model used to solve the problem is described in **Equation 4.1**.

## 2.2 Code description

A separate function file was created to execute the runge-kutta model
described in **Equation 4.1**. It contained a
*while* loop that computes, step by step, the x and y position of a
single particle, with a time step of 0.00001s. The output array was
pre-allocated as a zero array to attempt a faster computation. The
function was used in a *for* loop in the main code file in order to use
the runge-kutta function for all particles needed. The arrays containing
the position values for each particles were equally sized by filling the
smaller arrays with zeros to match the largest array. The x and y
positions for each particles as they travel through the pleat channel
are represented in the graph on **Figure 4.2**. The
positions of the particles were then recorded in a table for each 50th
time steps to shorten the table size, **Appendix C**.

# 3. Conclusions

## 3.1 Results

The graph in **Figure 4.2** shows that the particles
entering at a lower height travel a more horizontal path and travel for
a longer time than the particles entering at a higher height. It also
shows that particles do follow a parabolic travel path as expected.

# 4. Appendices

## 4.1 Appendix A - References

Chapra, Steven C., and Raymond P. Canale. Numerical Methods for
Engineers. New York: McGraw-Hill, 2015. Print.

## 4.2 Appendix B - Formulas

**Equation 4.1. Runge-Kutta fourth order**


${x_1}_{i+1}={x_1}_i+\frac{1}{6}({k_x}_{11}+2{k_x}_{21}+2{k_x}_{31}+{k_x}_{41})h$

${x_2}_{i+1}={x_2}_i+\frac{1}{6}({k_x}_{12}+2{k_x}_{22}+2{k_x}_{32}+{k_x}_{42})h$

${y_1}_{i+1}={y_1}_i+\frac{1}{6}({k_y}_{11}+2{k_y}_{21}+2{k_y}_{31}+{k_y}_{41})h$

${y_2}_{i+1}={y_2}_i+\frac{1}{6}({k_y}_{12}+2{k_y}_{22}+2{k_y}_{32}+{k_y}_{42})h$



where\
${k_x}_{11} = {f_x}_1(t, {x_1}_i , {x_2}_i , {y_1}_i , {y_2}_i)$\
${k_x}_{12} = {f_x}_2(t, {x_1}_i , {x_2}_i , {y_1}_i , {y_2}_i)$\
${k_y}_{11} = {f_y}_1(t, {x_1}_i , {x_2}_i , {y_1}_i , {y_2}_i)$\
${k_y}_{11} = {f_y}_2(t, {x_1}_i , {x_2}_i , {y_1}_i , {y_2}_i)$\
\
${k_x}_{21} = {f_x}_1(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{11} h, {x_2}_i + \frac{1}{2} {k_x}_{12} h , {y_1}_i + \frac{1}{2} {k_y}_{11} h , {y_2}_i + \frac{1}{2} {k_y}_{12} h)$\
${k_x}_{22} = {f_x}_2(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{11} h, {x_2}_i + \frac{1}{2} {k_x}_{12} h , {y_1}_i + \frac{1}{2} {k_y}_{11} h , {y_2}_i + \frac{1}{2} {k_y}_{12} h)$\
${k_y}_{21} = {f_y}_1(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{11} h, {x_2}_i + \frac{1}{2} {k_x}_{12} h , {y_1}_i + \frac{1}{2} {k_y}_{11} h , {y_2}_i + \frac{1}{2} {k_y}_{12} h)$\
${k_y}_{22} = {f_y}_2(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{11} h, {x_2}_i + \frac{1}{2} {k_x}_{12} h , {y_1}_i + \frac{1}{2} {k_y}_{11} h , {y_2}_i + \frac{1}{2} {k_y}_{12} h)$\
\
${k_x}_{31} = {f_x}_1(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{21} h, {x_2}_i + \frac{1}{2} {k_x}_{22} h , {y_1}_i + \frac{1}{2} {k_y}_{21} h , {y_2}_i + \frac{1}{2} {k_y}_{22} h)$\
${k_x}_{32} = {f_x}_2(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{21} h, {x_2}_i + \frac{1}{2} {k_x}_{22} h , {y_1}_i + \frac{1}{2} {k_y}_{21} h , {y_2}_i + \frac{1}{2} {k_y}_{22} h)$\
${k_y}_{31} = {f_y}_1(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{21} h, {x_2}_i + \frac{1}{2} {k_x}_{22} h , {y_1}_i + \frac{1}{2} {k_y}_{21} h , {y_2}_i + \frac{1}{2} {k_y}_{22} h)$\
${k_y}_{32} = {f_y}_2(t + \frac{1}{2} h ,  {x_1}_i + \frac{1}{2} {k_x}_{21} h, {x_2}_i + \frac{1}{2} {k_x}_{22} h , {y_1}_i + \frac{1}{2} {k_y}_{21} h , {y_2}_i + \frac{1}{2} {k_y}_{22} h)$\
\
${k_x}_{41} = {f_x}_1(t + h ,  {x_1}_i + {k_x}_{31} h, {x_2}_i + {k_x}_{32} h , {y_1}_i + {k_y}_{31} h , {y_2}_i + {k_y}_{32} h)$\
${k_x}_{42} = {f_x}_2(t + h ,  {x_1}_i + {k_x}_{31} h, {x_2}_i + {k_x}_{32} h , {y_1}_i + {k_y}_{31} h , {y_2}_i + {k_y}_{32} h)$\
${k_y}_{41} = {f_y}_1(t + h ,  {x_1}_i + {k_x}_{31} h, {x_2}_i + {k_x}_{32} h , {y_1}_i + {k_y}_{31} h , {y_2}_i + {k_y}_{32} h)$\
${k_y}_{42} = {f_y}_2(t + h ,  {x_1}_i + {k_x}_{31} h, {x_2}_i + {k_x}_{32} h , {y_1}_i + {k_y}_{31} h , {y_2}_i + {k_y}_{32} h)$

**Figure 4.1 Method to split higher order ODE into multiple first order ODEs**

![\[split ode\]Method to split higher order ODE into multiple
first order ODEs](split_ode.PNG "fig:")

## 4.3 Appendix C - Output

**Figure 4.2 Travel Path for Each Particles**

![\[project1_01\]Travel Path for Each
Particles](project1_01.png "fig:")

## 4.4 Appendix D - Input Code

**Function Code for Runge-Kutta 4th**

    function [xp,yp] = RK4(f1x,f2x,f1y,f2y,t,x10,x20,y10,y20,step,l,h,array)
    % The function will only output the required values of xp1 and yp1 as they
    % correspond to the xp and yp values while xp2 and yp2 correspond to the
    % first derivative

    % Preallocating each array for speed
    xp = array;
    yp = array;
    xp2 = array;
    yp2 = array;

    % Setting up the initial conditions as the starting terms of the loop
    xp(1)=x10;
    xp2(1)=x20;
    yp(1)=y10;
    yp2(1)=y20;

    m = 1;
    % Setting up a loop that breaks when either the particle position in x and
    % y reaches respectively l and h
    while (1)
        % Setting up the k1 coefficients for each x1,x2,y1,y2.
        kx11 = f1x(t , xp(m) , xp2(m) , yp(m) , yp2(m));
        kx12 = f2x(t , xp(m) , xp2(m) , yp(m) , yp2(m));
        ky11 = f1y(t , xp(m) , xp2(m) , yp(m) , yp2(m));
        ky12 = f2y(t , xp(m) , xp2(m) , yp(m) , yp2(m));

        % Setting up the k2 coefficients for each x1,x2,y1,y2.
        kx21 = f1x(t+0.5*step , xp(m)+kx11*step*0.5 , xp2(m)+kx12*step*0.5 ,...
            yp(m)+ky11*step*0.5 , yp2(m)+ky12*step*0.5);
        kx22 = f2x(t+0.5*step , xp(m)+kx11*step*0.5 , xp2(m)+kx12*step*0.5 ,...
            yp(m)+ky11*step*0.5 , yp2(m)+ky12*step*0.5);
        ky21 = f1y(t+0.5*step , xp(m)+kx11*step*0.5 , xp2(m)+kx12*step*0.5 ,...
            yp(m)+ky11*step*0.5 , yp2(m)+ky12*step*0.5);
        ky22 = f2y(t+0.5*step , xp(m)+kx11*step*0.5 , xp2(m)+kx12*step*0.5 ,...
            yp(m)+ky11*step*0.5 , yp2(m)+ky12*step*0.5);

        % Setting up the k3 coefficients for each x1,x2,y1,y2.
        kx31 = f1x(t+0.5*step , xp(m)+kx21*step*0.5 , xp2(m)+kx22*step*0.5 ,...
            yp(m)+ky21*step*0.5 , yp2(m)+ky22*step*0.5);
        kx32 = f2x(t+0.5*step , xp(m)+kx21*step*0.5 , xp2(m)+kx22*step*0.5 ,...
            yp(m)+ky21*step*0.5 , yp2(m)+ky22*step*0.5);
        ky31 = f1y(t+0.5*step , xp(m)+kx21*step*0.5 , xp2(m)+kx22*step*0.5 ,...
            yp(m)+ky21*step*0.5 , yp2(m)+ky22*step*0.5);
        ky32 = f2y(t+0.5*step , xp(m)+kx21*step*0.5 , xp2(m)+kx22*step*0.5 ,...
            yp(m)+ky21*step*0.5 , yp2(m)+ky22*step*0.5);

        % Setting up the k4 coefficients for each x1,x2,y1,y2.
        kx41 = f1x(t+step , xp(m)+kx31*step , xp2(m)+kx32*step ,...
            yp(m)+ky31*step , yp2(m)+ky32*step);
        kx42 = f2x(t+step , xp(m)+kx31*step , xp2(m)+kx32*step ,...
            yp(m)+ky31*step , yp2(m)+ky32*step);
        ky41 = f1y(t+step , xp(m)+kx31*step , xp2(m)+kx32*step ,...
            yp(m)+ky31*step , yp2(m)+ky32*step);
        ky42 = f2y(t+step , xp(m)+kx31*step , xp2(m)+kx32*step ,...
            yp(m)+ky31*step , yp2(m)+ky32*step);

        % Calculating simultaneously xp1, xp2 and yp1, yp2 values for each step
        % and storing them in an array
        xp(m+1) = xp(m)+1/6*(kx11+2*kx21+2*kx31+kx41)*step;
        xp2(m+1) = xp2(m)+1/6*(kx12+2*kx22+2*kx32+kx42)*step;
        yp(m+1) = yp(m)+1/6*(ky11+2*ky21+2*ky31+ky41)*step;
        yp2(m+1) = yp2(m)+1/6*(ky12+2*ky22+2*ky32+ky42)*step;
        m = m+1;
        t = t + step; % each step increases by the same increments

        % Setting the stopping terms for the loop
        if xp(m) >= l || yp(m) >= h, break;end
    end

**Main Code**

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

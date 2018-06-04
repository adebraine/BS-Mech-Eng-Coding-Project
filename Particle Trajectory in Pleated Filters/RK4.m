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


function [pumpspec,x,eq1] = plot_pump(maxflow,maxhead,count)

x = 1:1:maxflow;
eq1 = -maxhead/maxflow*x+maxhead;

y1 = linspace(0,maxhead,count);
i = 1;
for y = y1
    syms x1
    eq = y == -maxhead/maxflow*x1+maxhead;
    s = solve(eq);
    x2(i) = eval(s);
    i = i + 1;
end

pumpspec = table(y1(:),x2(:)/60,x2(:),'VariableNames',{'ft' 'GPM' 'GPH'});

end



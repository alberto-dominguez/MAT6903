function wt = Dist(d) 
    pd = makedist('Normal'); 
    wt = cdf(pd,d);
end
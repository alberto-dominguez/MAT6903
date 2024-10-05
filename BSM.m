function price = BSM(S,T,K,sigma,r,isput)
    d1 = 1/(sigma*sqrt(T))*(log(S/K) + (r + sigma^2/2)*T);
    d2 = d1 - sigma*sqrt(T);
    price = Dist(d1)*S - Dist(d2)*K*exp(-r*T);
    if isput
        price = price - S + K*exp(-r*T);
    end
end
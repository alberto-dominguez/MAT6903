function price = MJD(S,T,K,sigma,r,lam,mu,sigJ,isput)
    price = 0;
    for n=0:40
        sig_n = sqrt(sigma^2 + n*sigJ^2/T);
        r_n = r - lam*(mu-1) + n*log(mu)/T;
        price = price + (exp(-mu*lam*T) * (mu*lam*T)^n / factorial(n)) ...
                        * BSM(S,T,K,sig_n,r_n,isput);
    end
end
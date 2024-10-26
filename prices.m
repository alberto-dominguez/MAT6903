function option = prices(K,exp,paths1,p1,paths2,p2,isput)
    if isput
        put_payoff_1  = max(0, K - paths1(exp,:,:));
        put_payoff_2  = max(0, K - paths2(exp,:,:));
        option = mean(put_payoff_1)*p1 + mean(put_payoff_2)*p2;
    else
        call_payoff_1 = max(0, paths1(exp,:,:) - K);
        call_payoff_2 = max(0, paths2(exp,:,:) - K);
        option = mean(call_payoff_1)*p1 + mean(call_payoff_2)*p2;
    end
end
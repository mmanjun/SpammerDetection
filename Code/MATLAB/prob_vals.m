function [ att_prob_mean, unl_prob_mean ] = prob_vals( U_set, U_prob, RN_set )
%Finds values from results of hybrid.m to evaltuate operation
    
    users = U_set(1,:);
    
    indexed_prob = [users; U_prob];
    
    %It is assumed that all users within the RN set is NOT an attacker,
    %thus we assign 0 to the probability they are an attacker and 1 to the
    %probability they are not an attacker
    RN_prob = zeros(3,length(RN_set));
    RN_prob(1,:) = RN_set(1,:);
    
    for i = (1:length(RN_prob))
        RN_prob(3,i) = 1;
    end
    
    %Add RN users into indexed_prob
    indexed_prob = [indexed_prob RN_prob];
    
    %Since we know the attackers all have ids greater or equal to 2000...
    att_prob = indexed_prob(:,indexed_prob(1,:) >= 2000);
    unl_prob = indexed_prob(:,indexed_prob(1,:) < 2000);
    
    att_prob_mean(1) = sum(att_prob(2,:)) / length(att_prob);
    att_prob_mean(2) = sum(att_prob(3,:)) / length(att_prob);
    unl_prob_mean(1) = sum(unl_prob(2,:)) / length(unl_prob);
    unl_prob_mean(2) = sum(unl_prob(3,:)) / length(unl_prob);
end


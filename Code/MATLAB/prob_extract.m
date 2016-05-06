function [ U_prob ] = prob_extract( RN_set, U_set, P_set, RN_rated, user_rated, P_rated )
%PROB_EXTRACT Summary of this function goes here
%   Detailed explanation goes here
    
    %Feature order: user_deg_sim; user_len_var; user_rdma; user_fmtd; user_gfmv; user_tmf; user_pop_rank
    
    Lambda = 0.5;
    d = 0.2;
    Alpha = 1;
    Squiggle = 0.01;
    
    L_set = [RN_set P_set];
    L_rated = [RN_rated P_rated];
    
    %First, compute z_k using P_set, RN_set, and L_set
    z_k = zeros(2,1);
    z_k(1) = length(P_set) / length(L_set);
    z_k(2) = length(RN_set) / length(L_set);
    
    set_size = size(U_set);
    
    num_features = set_size(1) - 1;
    
    %Next, compute n_kl, n_k, and theta_k on the L_set initially
    n_kl = zeros(2,num_features);
    n_k = zeros(2,1);
    
    theta_kl = zeros(2,num_features);
    theta_k = zeros(2,1);
    
    L_num_features_k = zeros(2,num_features);
    
    for l = (1:num_features)
        
        L_num_features_k(1,l) = sum(P_set(l+1, :));
        L_num_features_k(2,l) = sum(RN_set(l+1, :));
        
        n_kl(1,l) = L_num_features_k(1,l);
        n_kl(2,l) = L_num_features_k(2,l);
    end
    
    n_k(1) = sum(n_kl(1,:));
    n_k(2) = sum(n_kl(2,:));
    
    for l = (1:num_features)
        if n_kl(1,l) == n_kl(2,l)
            theta_kl(1,l) = 0.5;
            theta_kl(2,l) = 0.5;
        elseif n_kl(1,l) == 0
            theta_kl(1,l) = 0;
            theta_kl(2,l) = 1;
        elseif n_kl(2,l) == 0
            theta_kl(1,l) = 1;
            theta_kl(2,l) = 0;
        else
            theta_kl(1,l) = n_kl(1,l) / n_k(1);
            theta_kl(2,l) = n_kl(2,l) / n_k(2);
        end
    end
    
    Y_prob = zeros(2,set_size(2));
    U_prob = zeros(2,set_size(2));
    OLD_Y_prob = zeros(2,set_size(2));
    
    Y_products = zeros(2,1);
    
    %Find certain values that won't change but are necessary in the loop
    item_array_length = zeros(1,length(user_rated));
    M_i = zeros(1,length(user_rated));
    
    for i = (1:length(user_rated))
        item_array_length(i) = length(user_rated(i).item);
        
        M_i(i) = d / item_array_length(i);
    end
    
    len_rated_sets = sum(item_array_length);
    C = 1 + d*len_rated_sets;
    
    iter = 0;
    
    while iter < 1000
        
        if iter > 0 
            if max(abs(U_prob-OLD_Y_prob)) <= 0.1
                break;
            end
        end
        if iter ~= 0
            OLD_Y_prob = U_prob;
        end
        
        iter = iter + 1;
        
        %Update U_prob then update Y_prob
        for i = (1:set_size(2))
            for k = (1:2)
                Y_prob(k,i) = prod(theta_kl(k,U_set(2:num_features+1,i) == 1));

                Y_products(k) = z_k(k)*Y_prob(k,i);
            end

            for k = (1:2)
                if sum(Y_products) == 0
                    U_prob(k,i) = 0;
                else
                    U_prob(k,i) = Y_products(k) / sum(Y_products);
                end
            end
        end
        
        %Update z_k, n_kl, n_k, and theta_kl
        z_k(1) = ( z_k(1) + Squiggle*( sum(U_prob(1,:)) / length(U_prob) ) );
        z_k(2) = ( z_k(2) + Squiggle*( sum(U_prob(2,:)) / length(U_prob) ) );
        
        for l = (1:num_features)
            n_kl(1,l) = n_kl(1,l) + Lambda*sum(U_prob(1, U_set(l+1,:) == 1));
            n_kl(2,l) = n_kl(2,l) + Lambda*sum(U_prob(2, U_set(l+1,:) == 1));
        end

        n_k(1) = sum(n_kl(1,:));
        n_k(2) = sum(n_kl(2,:));

        for k = (1:2)
            for l = (1:num_features)
                nominator = n_kl(k,l) + Alpha;
                denominator = n_k(k) + 2*Alpha;

                theta_kl(k,l) = nominator / denominator;
            end
        end
    end
    
    
end


function [ user_weighted_sim ] = weighted_sim( user, item, score, uniqueUsers, uniqueItems, avgItemRatings, user_rated )
%WEIGHTED_SIM Summary of this function goes here
%   Detailed explanation goes here

    user_weighted_sim = zeros(length(uniqueUsers));

    for i = (1:length(uniqueUsers))
        for j = (i+1:length(uniqueUsers))
            user_intersect = intersect(user_rated(i).item, user_rated(j).item);
            
            %If the users have no items in common, skip to next loop
            if isempty(user_intersect)
                continue;
            else
                user1_score = ones(1,length(user_intersect));
                user2_score = ones(1,length(user_intersect));
                avg_score = ones(1,length(user_intersect));
                
                for k = (1:length(user_intersect))
                    user1_score(k) = score(user == uniqueUsers(i) & item == user_intersect(k));
                    user2_score(k) = score(user == uniqueUsers(j) & item == user_intersect(k));
                    avg_score(k) = avgItemRatings(uniqueItems == user_intersect(k));
                end
                
                user1_minus_avg = minus(user1_score, avg_score);
                user2_minus_avg = minus(user2_score, avg_score);
                
                if sum(user1_minus_avg.^2) == 0 && sum(user2_minus_avg.^2) == 0
                    user_weighted_sim(i,j) = 1;
                elseif sum(user1_minus_avg.^2) == 0
                    sim_numerator = sum(user2_minus_avg);
                    sim_denominator = sum(user2_minus_avg.^2);
                    
                    user_weighted_sim(i,j) = sim_numerator / sim_denominator;
                elseif sum(user2_minus_avg.^2) == 0
                    sim_numerator = sum(user1_minus_avg);
                    sim_denominator = sum(user1_minus_avg.^2);
                    
                    user_weighted_sim(i,j) = sim_numerator / sim_denominator;
                else
                    sim_numerator = sum(user1_minus_avg.*user2_minus_avg);
                    sim_denominator = sqrt(sum(user1_minus_avg.^2)*sum(user2_minus_avg.^2));
                
                    user_weighted_sim(i,j) = sim_numerator / sim_denominator;
                end
                
                
                iteration = [i, j];
                disp(iteration);
            end
        end
    end

end


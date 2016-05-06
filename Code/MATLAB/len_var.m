function [ user_len_var ] = len_var( uniqueUsers,numUserReviews )
%LEN_VAR Summary of this function goes here
%   Detailed explanation goes here

    %------------------------
    %LengthVar Implementation
    %------------------------
    user_len_var = zeros(1,length(uniqueUsers));
    avg_num_reviews = sum(numUserReviews)/length(uniqueUsers);
    
        %Find LengthVar Denominator
    num_minus_avg = zeros(1,length(uniqueUsers));
    for i = (1:length(uniqueUsers))
        num_minus_avg(i) = (numUserReviews(i) - avg_num_reviews).^2;
    end
    len_var_denom = sum(num_minus_avg);
    
        %Find Each User's LengthVar
    for i = (1:length(uniqueUsers))
        user_len_var(i) = (abs(numUserReviews(i) - avg_num_reviews))/len_var_denom;
    end

end


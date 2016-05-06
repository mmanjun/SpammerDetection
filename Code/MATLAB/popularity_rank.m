function [ user_pop_rank ] = popularity_rank( uniqueUsers,uniqueItems,numUserReviews,numItemReviews, user, item )
%POP_RANK Summary of this function goes here
%   Detailed explanation goes here

    %------------------------
    %Popularity Rank Implementation
    %------------------------
    user_pop_rank = zeros(1, length(uniqueUsers));
        
    for i = (1:length(uniqueUsers))
        items_reviewed = item(user == uniqueUsers(i));
        
        num_user_reviews = zeros(1, length(items_reviewed));
        
        for j = (1:length(items_reviewed))
            num_user_reviews(j) = numItemReviews(uniqueItems == items_reviewed(j));
        end
        
        sumItemReviews = sum(num_user_reviews);
        
        user_pop_rank(i) = sumItemReviews / numUserReviews(i);
        
        %Find Set of items rated by each user
        %for j = (1:length(uniqueUsers2))
        %    items_rated(j) = item(user==uniqueUsers2(j));
        %end
        
        %Find set of users who  have reviewed an item
        %for k = (1:length(uniqueItems2))
        %    users_reviewed(k) = user(item==uniqueItems2(k));
        %end
        
        %pop_rank(i) =  pop_rank(i) + (items_rated(i)./users_reviewed(i));
    
    end
end
   
   
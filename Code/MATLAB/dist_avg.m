function [ dist_avg ] = dist_avg(user,item)

%To find the average distance with other users





    %------------------------
    %dist_avg Implementation
    %------------------------
   
    
       
        
       % [uniqueUsers,numUserReviews] = count_unique(user);
   % [uniqueItems,numItemReviews] = count_unique(item);
        
       % items_rated= struct('item',[]);
       % users_reviewed= struct('user',[]); 
       % pop_rank = struct('rank',[]);
       
       pcc= struct('pcc',[]);
       dist_avg= struct('dist',[]);
       
       
    for i = (1:length(user))
        
        
        for j= (1:length(item))
            
            A = [user(i) item(j)];
            pcc(i).pcc= corrcoef(A);
    
            dist_avg(i).dist= dist_avg(i).dist +(1-(pcc(i).pcc))/(length(user));
            
        end
            
    end 
end
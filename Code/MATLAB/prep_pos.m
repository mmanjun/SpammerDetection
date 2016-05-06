function [ pos_set ] = prep_pos( att1, att2, att3 )
%PREP_POS Prepares the set of attackers to be used in the positive set of
%         attackers for the hPSD function
%
%   Takes each type of attackers specified for the hPSD application and
%   places them into a continuous array of reviews for use as the positive
%   set of attackers in user reviews.
    
    all = [att1 att2 att3];
    size = length(all);
    
    att1_unique = count_unique([att1.reviewerID]);
    num1 = length(att1_unique);
    att2_unique = count_unique([att2.reviewerID]);
    num2 = length(att2_unique);
    
    size1 = length(att1);
    size2 = length(att2);
    
    pos_user = ones(1,size);
    for i = (1:size)
        if i <= size1
            pos_user(i) = att1(i).reviewerID + 1000;
        elseif i <= size2+size1
            pos_user(i) = att2(i-size1).reviewerID + num1 + 1000;
        else
            pos_user(i) = att3(i-size1-size2).reviewerID + num1 + num2 + 1000;
        end
    end
    
    pos_item = ones(1,size);
    for i = (1:size)
        if i <= size1
            pos_item(i) = str2double(att1(i).asin);
        elseif i <= size2+size1
            pos_item(i) = str2double(att2(i-size1).asin);
        else
            pos_item(i) = str2double(att3(i-size1-size2).asin);
        end
    end
    
    pos_score = [att1.overall att2.overall att3.overall];
    
    pos_time = ones(1,size);
    for i = (1:size)
        if i <= size1
            pos_time(i) = str2double(att1(i).reviewTime);
        elseif i <= size2+size1
            pos_time(i) = str2double(att2(i-size1).reviewTime);
        else
            pos_time(i) = str2double(att3(i-size1-size2).reviewTime);
        end
    end
    
    pos_set = [pos_user; pos_item; pos_score; pos_time];
end


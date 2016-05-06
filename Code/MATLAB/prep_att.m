function [ att_set ] = prep_att( att1, att2, att3, att4, att5, att6 )
%PREP_ATT Prepares the set of attackers for use in hPSD function
%
%   Takes each type of attackers specified for the hPSD application and
%   places them into a continuous array of reviews for injection into the
%   unlabeled set of user reviews.
    
    all = [att1 att2 att3 att4 att5 att6];
    size = length(all);
    
    att1_unique = count_unique([att1.reviewerID]);
    num1 = length(att1_unique);
    att2_unique = count_unique([att2.reviewerID]);
    num2 = length(att2_unique);
    att3_unique = count_unique([att3.reviewerID]);
    num3 = length(att3_unique);
    att4_unique = count_unique([att4.reviewerID]);
    num4 = length(att4_unique);
    att5_unique = count_unique([att5.reviewerID]);
    num5 = length(att5_unique);
    
    size1 = length(att1);
    size2 = length(att2);
    size3 = length(att3);
    size4 = length(att4);
    size5 = length(att5);
    
    att_user = ones(1,size);
    for i = (1:size)
        if i <= size1
            att_user(i) = att1(i).reviewerID;
        elseif i <= size1+size2
            att_user(i) = att2(i-size1).reviewerID + num1;
        elseif i <= size1+size2+size3
            att_user(i) = att3(i-size1-size2).reviewerID + num1 + num2;
        elseif i <= size1+size2+size3+size4
            att_user(i) = att4(i-size1-size2-size3).reviewerID + num1 + num2 + num3;
        elseif i <= size1+size2+size3+size4+size5
            att_user(i) = att5(i-size1-size2-size3-size4).reviewerID + num1 + num2 + num3 + num4;
        else
            att_user(i) = att6(i-size1-size2-size3-size4-size5).reviewerID + num1 + num2 + num3 + num4 + num5;
        end
    end
    
    att_item = ones(1,size);
    for i = (1:size)
        if i <= size1
            att_item(i) = str2double(att1(i).asin);
        elseif i <= size1+size2
            att_item(i) = str2double(att2(i-size1).asin);
        elseif i <= size1+size2+size3
            att_item(i) = str2double(att3(i-size1-size2).asin);
        elseif i <= size1+size2+size3+size4
            att_item(i) = str2double(att4(i-size1-size2-size3).asin);
        elseif i <= size1+size2+size3+size4+size5
            att_item(i) = str2double(att5(i-size1-size2-size3-size4).asin);
        else
            att_item(i) = str2double(att6(i-size1-size2-size3-size4-size5).asin);
        end
    end
    
    att_score = [att1.overall att2.overall att3.overall att4.overall att5.overall att6.overall];
    
    att_time = ones(1,size);
    for i = (1:size)
        if i <= size1
            att_time(i) = str2double(att1(i).reviewTime);
        elseif i <= size1+size2
            att_time(i) = str2double(att2(i-size1).reviewTime);
        elseif i <= size1+size2+size3
            att_time(i) = str2double(att3(i-size1-size2).reviewTime);
        elseif i <= size1+size2+size3+size4
            att_time(i) = str2double(att4(i-size1-size2-size3).reviewTime);
        elseif i <= size1+size2+size3+size4+size5
            att_time(i) = str2double(att5(i-size1-size2-size3-size4).reviewTime);
        else
            att_time(i) = str2double(att6(i-size1-size2-size3-size4-size5).reviewTime);
        end
    end

    att_set = [att_user; att_item; att_score; att_time];
end


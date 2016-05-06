function [RN_set, U_set, P_set, RN_rated, user_rated, P_rated, item_rated, RN_lengths, RN_att_precision ] = rn_extract(data, pos_set, att_set)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  IMPORTANT NOTE: Remove all %%COMMENTED OUT FOR FASTER TESTING%%  %%%
%%%                  Once the program is complete                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO2: Removed user_deg_sim due to excessive computation time


% To find the Reliable Negative Set we must take 'data' and 'P'
% And must determine the following features from these sets:
%   DegSim
%   LengthVar
%   RDMA
%   FMTD
%   GFMV
%   TMF
%   PopRank

    %Determine important information and split data into arrays
    dat_length = length(data);
    user = ones(1,dat_length);
    for i = (1:dat_length)
        user(i) = str2double(data(i).reviewerID);
    end
    
    item = ones(1,dat_length);
    for i = (1:dat_length)
        item(i) = str2double(data(i).asin);
    end
    
    score = [data.overall];
    
    time = ones(1,dat_length);
    for i = (1:dat_length)
        time(i) = str2double(data(i).reviewTime);
    end
    
    
    %Determine size of attacking set and break into appropriate pieces
    att_length = length(att_set);
    att_user = att_set(1,1:att_length);
    att_item = att_set(2,1:att_length);
    att_score = att_set(3,1:att_length);
    att_time = att_set(4,1:att_length);
    
    %Determine size of positive labeled set and break into pieces
    pos_length = length(pos_set);
    pos_user = pos_set(1,1:pos_length);
    pos_item = pos_set(2,1:pos_length);
    pos_score = pos_set(3,1:pos_length);
    pos_time = pos_set(4,1:pos_length);
    
    %Inject known attackers and positives into the unlabeled set of reviews
    user = [user att_user pos_user];
    item = [item att_item pos_item];
    score = [score att_score pos_score];
    time = [time att_time pos_time];
    
    %data_matrix = zeros(4,length(user));
    %data_matrix(1) = user;
    %data_matrix(2) = item;
    
    %Determine unique users and unique items for each set
    %  as well as number of reviews per user / items
    [uniqueUsers,numUserReviews] = count_unique(user);
    [uniqueItems,numItemReviews] = count_unique(item);
    
    [att_uniqueUsers, att_numUserReviews] = count_unique(att_user);
    [att_uniqueItems,att_numItemReviews] = count_unique(att_item);
    
    [pos_uniqueUsers, pos_numUserReviews] = count_unique(pos_user);
    
    maxUserReviews = max(numUserReviews);
    maxItemReviews = max(numItemReviews);
    
    %Determine the average rating on all items reviewed by each user
    %  ALSO determines Target set and Filler set for each user
    avgUserRatings = zeros(1,length(uniqueUsers));
    ratingSum = 0;
    
    %The target and filler arrays store the positions in the data of the
    %  reviews relating to the items in the set. To find the particular
    %  items in those sets, use item(userSets(x).target(y))
    
    posArray = [];
    
    for i = (1:length(uniqueUsers))
        dataPositionArray = find(user == uniqueUsers(i));
        
        for j = (1:length(dataPositionArray))
            ratingSum = ratingSum + score(dataPositionArray(j));
        end
        
        avgUserRatings(i) = ratingSum / numUserReviews(i);
        
        ratingSum = 0;
    end
    
    %Determine average rating of all user reviews on each item
    avgItemRatings = zeros(1,length(uniqueItems));
    
    for i = (1:length(uniqueItems))
        itemPositionArray = find(item == uniqueItems(i));
        
        for j = (1:length(itemPositionArray))
            ratingSum = ratingSum + score(itemPositionArray(j));
        end
        
        avgItemRatings(i) = ratingSum / numItemReviews(i);
        
        ratingSum = 0;
    end
    
    %Create an array of structs of the items reviewed by each user
    %  ORDERED BY: uniqueUsers
    user_rated = struct('user', [], 'item', []);
    
    for i = (1:length(uniqueUsers))
        user_rated_items = item(user == uniqueUsers(i));
        
        user_rated(i).user = uniqueUsers(i);
        user_rated(i).item = user_rated_items;
    end
    
    %Create an array of structs of the users that reviewed each item
    item_rated = struct('item', [], 'user', []);
    
    for i = (1:length(uniqueItems))
        item_rated_users = user(item == uniqueItems(i));
        
        item_rated(i).item = uniqueItems(i);
        item_rated(i).user = item_rated_users;
    end
    
    %Weighted Similarity between users who reviewed similar items
    %%TODO2: Removed due to excessive computation time
    %user_weighted_sim = weighted_sim( user, item, score, uniqueUsers, uniqueItems, avgItemRatings, user_rated );
    
    %DegSim (needs Weighted Similarity)
    %TODO2: Removed due to excessive computation time
    %{
    user_deg_sim = zeros(1,length(uniqueUsers));
    
    num_closest_neighbors = round(length(uniqueUsers)/20);
    
    for i = (1:length(user_deg_sim))
        neighbors = zeros(1, length(uniqueUsers));
        
        for j = (1:length(neighbors))
            if j < i
                neighbors(j) = user_weighted_sim(j,i);
            elseif j > i
                neighbors(j) = user_weighted_sim(i,j);
            end
        end
        
        neighbors = abs(neighbors);
        
        [nei_sort, nei_index] = sort(neighbors, 'descend');
        
        if isempty(nei_sort)
            user_deg_sim(i) = 0;
        else
            user_deg_sim(i) = (sum(nei_sort(1:num_closest_neighbors))) / num_closest_neighbors;
        end
        
        %{
        if isnan(user_deg_sim(i))
            disp(i);
            disp(nei_sort(1:num_closest_neighbors));
            disp(nei_index(1:num_closest_neighbors));
            pause;
        end
        %}
    end
    %}
    
    %Length Variance of users based on number of reviews
    %%COMMENTED OUT FOR FASTER TESTING%%
    [user_len_var] = len_var(uniqueUsers,numUserReviews);
    
    %RDMA of users
    %  NEEDED avgItemRatings
    user_rdma = zeros(1,length(uniqueUsers));
    rdma_numerator = 0;
    
    for i = (1:length(uniqueUsers))
        %Find the positions in the data where the user gives reviews
        dataPositionArray = find(user == uniqueUsers(i));
        
        %Next we must determine the numerator of the RDMA function
        %Since it is a sum over each of the items the user has reviewed...
        %  For each of the reviews...
        for j = (1:length(dataPositionArray))
            %Locate the position of the item reviewed in the "uniqueItems" array
            uniqueItemPosition = find(uniqueItems == item(dataPositionArray(j)));
            
            %Then perform the numerator calculation and add them together
            rdma_numerator = rdma_numerator + ( abs( score(dataPositionArray(j)) - avgItemRatings(uniqueItemPosition) ) / numItemReviews(uniqueItemPosition) );
        end
        
        %Take the numberator and divide it by the users total # of reviews
        user_rdma(i) = rdma_numerator / numUserReviews(i);
        
        %Finally, reset the numerator before moving on to the next user
        rdma_numerator = 0;
    end
    
    %FMTD & GFMV (or Group FMV)
    user_fmtd = zeros(1,length(uniqueUsers));
    user_gfmv = zeros(1,length(uniqueUsers));
    
    userSets = struct('target', [], 'filler', []);
    item_target_count = zeros(1, length(uniqueItems));
    
    for i = (1:length(uniqueUsers))
        user_target = [];
        user_filler = [];
        
        %Find the positions in the data where the user gives reviews
        dataPositionArray = find(user == uniqueUsers(i));
        
        for j = (1:length(dataPositionArray))
            if score(dataPositionArray(j)) == 5
                user_target = [user_target dataPositionArray(j)];
                item_target_count(uniqueItems == item(dataPositionArray(j))) = item_target_count(uniqueItems == item(dataPositionArray(j))) + 1;
            else
                user_filler = [user_filler dataPositionArray(j)];
            end
        end
        
        userSets(i).target = user_target;
        userSets(i).filler = user_filler;
        
        %Find FMTD
        if ~isempty(user_target)
            fmtd_left = ( sum(score(user_target)) / length(user_target) );
        else
            fmtd_left = 0;
        end
        
        if ~isempty(user_filler)
            fmtd_right = ( sum(score(user_filler)) / length(user_filler) );
        else
            fmtd_right = 0;
        end
        
        user_fmtd(i) = abs( fmtd_left - fmtd_right );
        
        %Find GFMV
        gfmv_numerator = 0;
        
        for j = (1:length(user_filler))
            gfmv_numerator = gfmv_numerator + (score(user_filler(j)) - avgItemRatings(uniqueItems == item(user_filler(j)))).^2;
        end
        
        user_gfmv(i) = gfmv_numerator / length(user_filler);
        
    end
    
    %Subtract average user_fmtd from each value of user_fmtd
    avg_fmtd = mean(user_fmtd);
    user_fmtd = minus(user_fmtd, avg_fmtd);
    
    %TMF
    item_target_focus = zeros(1, length(uniqueItems));
    user_tmf = zeros(1, length(uniqueUsers));
    
    total_target_count = sum(item_target_count);
    
    %Find item_target_focus for each item
    for i = (1:length(uniqueItems))
        item_target_focus(i) = item_target_count(i) / total_target_count;
    end
    
    for i = (1:length(uniqueUsers))
        for j = (1:length(userSets(i).target))
            user_tmf(i) = max(user_tmf(i), item_target_focus(uniqueItems == item(userSets(i).target(j))));
        end
    end
    
    
    %Pop_Rank
    [ user_pop_rank ] = popularity_rank( uniqueUsers, uniqueItems, numUserReviews, numItemReviews, user, item );
    
    %Feature Discretization
    
    %%% TODO2: Removed user_deg_sim due to excessive computation time
    %feature_matrix = [user_deg_sim; user_len_var; user_rdma; user_fmtd; user_gfmv; user_tmf; user_pop_rank];
    feature_matrix = [user_len_var; user_rdma; user_fmtd; user_gfmv; user_tmf; user_pop_rank];
    
    num_features = size(feature_matrix);
    num_features = num_features(1);
    len = length(uniqueUsers);
    
    feature_cutoff = zeros(1, num_features);
    
    weighted_avg_var = zeros(num_features, len-1);
    
    sorted_feature_index = zeros(num_features, length(uniqueUsers));
    feature_sorted = zeros(num_features, length(uniqueUsers));
    
    %For all features...
    for i = (1:num_features)
        [feature_sorted(i,:), feature_sorted_index(i,:)] = sort(feature_matrix(i,:), 'ascend');
        
        if i == 6
            disp(feature_sorted(i,:));
        end
        
        %Find Weighted Average Variance for each cut point
        for j = (1:length(weighted_avg_var))
            weighted_avg_var(i,j) = (j/len)*var(feature_sorted(i,1:j)) + ((len-j)/len)*var(feature_sorted(i,j+1:len));
        end
        
        %User minimum Weighted Average Variance to determine feature cutoff
        [ z, feature_cutoff(i) ] = min(weighted_avg_var(i,:));
    end
     
    feature_dis_mat = zeros(num_features, length(uniqueUsers));
    
    %For all features...
    for i = (1:num_features)
        %For all users, determine if they have or don't have the feature
        for j = (feature_cutoff(i):length(uniqueUsers))
            feature_dis_mat(i,feature_sorted_index(i,j)) = 1;
        end
    end
    
    %At this point we insert the uniqueUser ids into the feature matrix so
    %that we can keep track of which users are contained in which set
    %easily.
    feature_dis_mat = [uniqueUsers'; feature_dis_mat];
    
    U_set = feature_dis_mat(:,1:(length(uniqueUsers)-length(pos_uniqueUsers)));
    P_set = feature_dis_mat(:,(length(uniqueUsers)-length(pos_uniqueUsers))+1:length(feature_dis_mat));
    
    dat_feature_num = zeros(1,num_features);
    pos_feature_num = zeros(1,num_features);
    D_value = zeros(1, num_features);
    
    %For loop starts at 2 because index 1 contains user ids
    for i = (1:num_features)
        dat_feature_num(i) = sum(U_set(:,i+1));
        pos_feature_num(i) = sum(P_set(:,i+1));
        
        D_value(i) = pos_feature_num(i)*log(length(uniqueUsers)/(pos_feature_num(i) + dat_feature_num(i)));
    end
    
    
    [D_sort, D_index] = sort(D_value, 'descend');
    
    %As we will use the D_index to determine the features to check in order
    %using a matrix containing the user ids in the first index, we
    %increment all index numbers by 1
    D_index = D_index + 1;
    
    %We can use dat_feature_dis as the initial RN_set
    RN_set = U_set;
    dist_old = abs(length(RN_set) - length(pos_uniqueUsers));
    best_RN = 1;
    
    RN_array = struct('set', []);
    
    RN_array(1).set = RN_set;
    RN_lengths = zeros(1,num_features);
    RN_att_precision = zeros(1,num_features);
    
    for i = (1:length(D_value))
        RN_set(:, RN_set(D_index(i),:) == 1) = [];
        att_remaining = RN_set(1,RN_set(1,:) >= 2000);
        
        RN_array(i+1).set = RN_set;
        RN_lengths(i) = length(RN_set);
        RN_att_precision(i) = ( RN_lengths(i) - length(att_remaining) ) / RN_lengths(i);
    end
    
    for i = (2:length(RN_array))
        if ~isempty(RN_array(i).set)
            dist_new = abs(length(RN_array(i).set) - length(pos_uniqueUsers));

            if dist_new < dist_old
                best_RN = i;
                dist_old = dist_new;
            end
        else
            %If we've reached the point that the RN_set is empty, break out
            %of the loop as we will not consider empty RN_sets
            break;
        end
    end
    
    RN_set = RN_array(best_RN).set;
    
    %Store rated items for each of the sets
    P_rated = user_rated((length(uniqueUsers)-length(pos_uniqueUsers))+1:length(user_rated));
    user_rated = user_rated(1:(length(uniqueUsers)-length(pos_uniqueUsers)));
    RN_rated = struct('user', [], 'item', []);
    
    %Remove all users that remain in the RN_set from the unlabeled set
    for i = (1:length(RN_set))
        U_set(:, U_set(1,:) == RN_set(1,i)) = [];
        
        %Insert RN user
        RN_rated(i).user = RN_set(1,i);
        
        %Find RN user in user_rated struct, place item set into RN_set
        %struct, then remove entry from user_rated
        for j = (1:length(user_rated))
            if user_rated(j).user == RN_set(1,i)
                RN_rated(i).item = user_rated(j).item;
                user_rated(j) = [];
                break;
            end
        end
    end
    
    
end
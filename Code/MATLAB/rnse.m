function[rns]= rnse(P, U, fp, fU)

% Reliable Negative Set Extraction Algorithm Implementation
%P : Positive set of labeled spammers
%U : Unlabeled set of users
%fp = Features appearing in P

    Rn = U; % Initially, Rn <- U
    Dfl = zeros(1,length(fp));

    for i = (1:length(fp))
        Dfl(i) = feature_disc(numPositive,numUsers,fp(i),np,nu); 
    end
 
   Dfl_des = sort(Dfl,'descend');
   
    for i=(1:length(Dfl_des))
        for j= (1:length(fU))
            if(Dfl(i)==fU(j))
                Rn(i) = [];
            end
        end
    end

    if(size(Rn) <= size(P))
        rns = Rn; 
    end

end
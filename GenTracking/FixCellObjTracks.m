function CellsOut = FixCellObjTracks(CellsIn, thresh, massfact, maxdeltat)
%function CellsOut = FixCellObjTracks(CellsIn, thresh)
%function to fix cell object tracks

%set up tf vector and initialize numC
numC = length(CellsIn);
tf = zeros(numC,1);
for ii = 1:numC
    tf(ii) = CellsIn(ii).time(end);
end

CellsOut = CellsIn;

%loop through tf vector until all entries filled with NaN
while sum(isnan(tf)) < numC
    [~,currC] = min(tf); %get index of first minimum value in tf, this is the current cell
    score = zeros(numC,1); %remake score array (necessary because numC changes as cells are merged)
    for ii = 1:numC
        deltat = CellsOut(ii).time(1)-CellsOut(currC).time(end);
        if ii == currC || deltat>maxdeltat || deltat<0 || isnan(tf(ii)) || CellsOut(currC).LocNum ~= CellsOut(ii).LocNum %if at current cell, deltat is too large, deltat is negative, tf is NaN, or if Locs don't match, score is nan
            score(ii) = NaN;
        else %otherwise, compute score
            score(ii) = norm([CellsOut(currC).x(end)-CellsOut(ii).x(1),CellsOut(currC).y(end)-CellsOut(ii).y(1), massfact./CellsOut(currC).mass(end).*(CellsOut(currC).mass(end)-CellsOut(ii).mass(1))]);
        end
    end
    
    %find min score
    [minscore, mergeC] = min(score);
    
    %if min below threshold, then combine cells, update tf, update numC
    if minscore < thresh
        CellsOut = MergeCellObjs(CellsOut, currC, mergeC);
        tf(currC) = tf(mergeC);
        tf = tf([1:mergeC-1,mergeC+1:end]);
        numC = length(tf);
        %otherwise, tf replaced by NaN (to indicate we are done with this cell)
    else
        tf(currC) = NaN;
    end
end
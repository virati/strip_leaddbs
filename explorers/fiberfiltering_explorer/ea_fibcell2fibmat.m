function fibers = ea_fibcell2fibmat(fibers)
% EA_FIBCELL2FIBMAT Convert fiber cell array to matrix format
%
% Input:
%   fibers - Cell array where each cell contains fiber coordinates (Nx3)
%
% Output:
%   fibers - Matrix with fiber coordinates and fiber IDs
%            Format: [x, y, z, fiber_id] where fiber_id identifies which
%            fiber each point belongs to
%
% This function was extracted from ea_discfibers_calcvals_cleartune.m and
% ea_disctract.m to eliminate code duplication.

[idx,~]=cellfun(@size,fibers);
fibers=cell2mat(fibers);
idxv=zeros(size(fibers,1),1);
lid=1; cnt=1;
for id=idx'
    idxv(lid:lid+id-1)=cnt;
    lid=lid+id;
    cnt=cnt+1;
end
fibers=[fibers,idxv];

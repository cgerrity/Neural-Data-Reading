function cfg = cgg_saveTemporaryData(X_input,Y_input,cfg)
%CGG_SAVETEMPORARYDATA Summary of this function goes here
%   Detailed explanation goes here

NumData=gather(length(Y_input));

FolderNames=unique(gather(Y_input));

NumFolders=length(FolderNames);

X_NameExt = 'X_%d.mat';

for fidx=1:NumFolders

    this_FolderName=sprintf('Dimension_%d',FolderNames(fidx));

% Make the Data folder names.
cfg_tmp=cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch.Data;
[cfg_tmp,~] = cgg_generateFolderAndPath(this_FolderName,this_FolderName,cfg_tmp);
cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch.Data=cfg_tmp;

end

cfg_Data=cfg.TemporaryDir.Aggregate_Data.Epoched_Data.Epoch.Data;

ChunkSize=1000;

NumChunks=ceil(NumData/ChunkSize);

for cidx=1:NumChunks

% disp(sprintf('Chunk: %d',cidx));

ChunkStart=ChunkSize*(cidx-1)+1;
ChunkEnd=ChunkSize*(cidx);

ChunkEnd(ChunkEnd>NumData)=NumData;

ChunkIndices=ChunkStart:ChunkEnd;

this_XChunk=gather(X_input(ChunkIndices,:));
this_YChunk=gather(Y_input(ChunkIndices));

this_NumChunks=length(ChunkIndices);

parfor didx=1:this_NumChunks
    this_IDX=ChunkIndices(didx);

this_X=this_XChunk(didx,:);
this_Y=this_YChunk(didx);

this_FolderName=sprintf('Dimension_%d',this_Y);
this_Dir=cfg_Data.(this_FolderName).path;

this_X_PathNameExt=sprintf([this_Dir filesep X_NameExt],this_IDX);

m_X = matfile(this_X_PathNameExt,'Writable',true);
m_X.X=this_X;

end
end

end


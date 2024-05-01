function [CM_Table] = cgg_procPredictionsFromDatastore(InDatastore,Mdl,ClassNames,varargin)
%CGG_PROCCONFUSIONMATRIXFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
DimensionNumber = CheckVararginPairs('DimensionNumber', 1, varargin{:});
else
if ~(exist('DimensionNumber','var'))
DimensionNumber=1;
end
end

NumDatastore=numpartitions(InDatastore);

ClassNames=diag(diag(ClassNames));

wantZeroFeatureDetector=false;
if numel(Mdl)>1
    wantZeroFeatureDetector=true;
end

%%

CM_Cell=cell(1,NumDatastore);

parfor didx=1:NumDatastore
    this_tmp_Datastore=partition(InDatastore,NumDatastore,didx);
    this_Values=read(this_tmp_Datastore);
    FileName=this_tmp_Datastore.UnderlyingDatastores{1}.Files;
    [this_DataNumber,~] = cgg_getNumberFromFileName(FileName);
    this_X=this_Values{1};
    [NumWindows,~]=size(this_X);
    this_TrueValue=this_Values{2}(DimensionNumber);

    this_CM_Table=[];

    for widx=1:NumWindows

        if wantZeroFeatureDetector && length(ClassNames)==1
            [this_Y,ClassConfidence,~] = cgg_procPredictionsFromModels(Mdl{1},this_X(widx,:));
        else

        [this_Y,ClassConfidence,~] = cgg_procPredictionsFromModels(Mdl,this_X(widx,:));

            if wantZeroFeatureDetector
                if this_Y{1}==0
                    this_Y=0;
                elseif this_Y{1}==1
                    this_Y=this_Y{2};
                else
                end
                ClassConfidence=cell2mat(ClassConfidence);
            end
        end

    this_WindowName=sprintf('Window_%d',widx);
    this_WindowName_Confidence=sprintf('Window_%d_Confidence',widx);
    if widx==1
    this_CM_Table = table(this_DataNumber,this_TrueValue,ClassNames',...
  this_Y,ClassConfidence,'VariableNames',{'DataNumber','TrueValue','ClassNames',this_WindowName,this_WindowName_Confidence});
    else
    this_CM_Table.(this_WindowName)=this_Y;
    this_CM_Table.(this_WindowName_Confidence)=ClassConfidence;
    end
%         if widx==1
%         this_CM_Table = table(this_DataNumber,this_TrueValue,ClassNames',...
%       ClassConfidence,'VariableNames',{'DataNumber','TrueValue','ClassNames',this_WindowName});
%         else
%         this_CM_Table.(this_WindowName)=ClassConfidence;
%         end

    end

    CM_Cell{didx}=this_CM_Table

end
%%
clear('CM_Table');
for didx=1:NumDatastore
this_CM_Table=CM_Cell{didx};
if exist('CM_Table','var')
CM_Table = cgg_getCombineTablesWithMissingColumns(CM_Table,this_CM_Table);
else
CM_Table=this_CM_Table;
end
end

end


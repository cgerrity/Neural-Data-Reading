function MdlDecoder = cgg_loadDecoderModels_v2(Decoder,NumClasses,DecoderModel_PathNameExt)
%CGG_LOADDECODERMODELS Summary of this function goes here
%   Detailed explanation goes here

%% Parameters
cfg_NameParameters = NAMEPARAMETERS_cgg_nameVariables;

ZeroFeatureTableName=cfg_NameParameters.ZeroFeatureTableName;
FeatureTableName=cfg_NameParameters.FeatureTableName;
AllTableName=cfg_NameParameters.AllTableName;

ExtraSaveTermZeroFeature=cfg_NameParameters.ExtraSaveTermZeroFeature;

%%

NumDimensions=length(NumClasses);

wantZeroFeatureDetector=false;
if contains(DecoderModel_PathNameExt,['_' ExtraSaveTermZeroFeature])
wantZeroFeatureDetector=true;
end

if isfile(DecoderModel_PathNameExt)
m_DecoderModel = matfile(DecoderModel_PathNameExt,'Writable',false);
MdlDecoder = m_DecoderModel.ModelDecoder;
else
 
    if wantZeroFeatureDetector
    MdlDecoderZero=cell(NumDimensions,1);
    MdlDecoderFeature=cell(NumDimensions,1);
    else
    MdlDecoderAll=cell(NumDimensions,1);
    end

    RowName=cell(NumDimensions,1);

    for fdidx=1:NumDimensions
    NumFeatures=max([NumClasses(fdidx)-1,1]);
    if wantZeroFeatureDetector
    MdlDecoderZero{fdidx}=cgg_loadDecoderModels(Decoder,2,'');
    MdlDecoderFeature{fdidx}=cgg_loadDecoderModels(Decoder,NumFeatures,'');
    else
    MdlDecoderAll{fdidx}=cgg_loadDecoderModels(Decoder,NumClasses(fdidx),'');
    end

    RowName{fdidx}=sprintf('Dimension_%d',fdidx);
    end

    if wantZeroFeatureDetector
        MdlDecoder=table(MdlDecoderZero,MdlDecoderFeature,'VariableNames',{ZeroFeatureTableName,FeatureTableName},'RowNames',RowName);
    else
        MdlDecoder=table(MdlDecoderAll,'VariableNames',{AllTableName},'RowNames',RowName);
    end
end


end


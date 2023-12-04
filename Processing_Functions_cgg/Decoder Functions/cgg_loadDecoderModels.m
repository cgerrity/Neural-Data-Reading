function MdlDecoder = cgg_loadDecoderModels(Decoder,NumClasses,DecoderModel_PathNameExt)
%CGG_LOADDECODERMODELS Summary of this function goes here
%   Detailed explanation goes here



if isfile(DecoderModel_PathNameExt)
m_DecoderModel = matfile(DecoderModel_PathNameExt,'Writable',false);
MdlDecoder = m_DecoderModel.ModelDecoder;
else

    switch Decoder
        case 'Logistic'
            binaryMdl = incrementalClassificationLinear(Learner="logistic",Standardize=true);
            MdlDecoder = incrementalClassificationECOC(MaxNumClasses=NumClasses,Coding="onevsall",Learners=binaryMdl);
        case 'SVM'
            binaryMdl = incrementalClassificationLinear(Learner="svm",Standardize=true);
            MdlDecoder = incrementalClassificationECOC(MaxNumClasses=NumClasses,Coding="onevsall",Learners=binaryMdl);
        case 'Gaussian-Logistic'
            binaryMdl = incrementalClassificationKernel(Learner="logistic");
            MdlDecoder = incrementalClassificationECOC(MaxNumClasses=NumClasses,Coding="onevsall",Learners=binaryMdl);
        case 'Gaussian-SVM'
            binaryMdl = incrementalClassificationKernel(Learner="svm");
            MdlDecoder = incrementalClassificationECOC(MaxNumClasses=NumClasses,Coding="onevsall",Learners=binaryMdl);
        case 'NaiveBayes'
            MdlDecoder = incrementalClassificationNaiveBayes('MaxNumClasses',NumClasses);
        otherwise
            binaryMdl = incrementalClassificationLinear(Learner="logistic",Standardize=true);
            MdlDecoder = incrementalClassificationECOC(MaxNumClasses=NumClasses,Coding="onevsall",Learners=binaryMdl);
    end

end


end


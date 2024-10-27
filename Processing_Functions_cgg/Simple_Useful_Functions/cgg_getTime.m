function Time = cgg_getTime(Time_Start,SamplingRate,DataWidth,WindowStride,NumWindows,TimeOffset)
%CGG_GETTIME Summary of this function goes here
%   Detailed explanation goes here

DataWidth = DataWidth/SamplingRate;
WindowStride = WindowStride/SamplingRate;

Time_Start_Adjusted = Time_Start+DataWidth/2+TimeOffset;

Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
end


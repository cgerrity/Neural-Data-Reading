function ArrayListString = cgg_getArrayListString(Array,options)
%UNTITLED16 Summary of this function goes here
%   This function takes an array and turns it into a string where each
%   element of the array is comma separated
arguments (Input)
    Array
    options.Format = '%.2f'
end

arguments (Output)
    ArrayListString
end

%%

NumElements = length(Array);

ArrayListString_Format = [repmat([options.Format, ', '],1,NumElements-1), options.Format];
ArrayListString = sprintf(ArrayListString_Format,Array);

end
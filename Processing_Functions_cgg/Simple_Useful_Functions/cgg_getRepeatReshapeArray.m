function output = cgg_getRepeatReshapeArray(input_array, output_size, non_repeated_dims)
    % CGG_GETREPEATRESHAPEARRAY Reshapes and repeats an array along specified dimensions
    %
    % Inputs:
    %   input_array - Input array of any size
    %   output_size - Desired output size as a vector [dim1, dim2, ..., dimN]
    %   non_repeated_dims - Dimensions that should NOT be repeated (values remain constant)
    %
    % Output:
    %   output - Reshaped and repeated array with specified output size
    
    % Get dimensions
    input_size = size(input_array);
    n_output_dims = length(output_size);
    
    % Determine which dimensions to repeat
    all_dims = 1:n_output_dims;
    repeated_dims = setdiff(all_dims, non_repeated_dims);
    
    % Calculate the size needed for non-repeated dimensions
    non_repeated_size = output_size(non_repeated_dims);
    
    % Reshape input to match non-repeated dimensions
    total_elements = numel(input_array);
    expected_elements = prod(non_repeated_size);
    
    if total_elements ~= expected_elements
        error('Input array size (%d elements) does not match expected size for non-repeated dimensions (%d elements)', ...
              total_elements, expected_elements);
    end
    
    % Create reshape size vector
    reshape_size = ones(1, n_output_dims);
    reshape_size(non_repeated_dims) = non_repeated_size;
    
    % Reshape the input array
    reshaped_array = reshape(input_array, reshape_size);
    
    % Create repmat size vector
    repmat_size = ones(1, n_output_dims);
    repmat_size(repeated_dims) = output_size(repeated_dims);
    
    % Repeat along specified dimensions
    output = repmat(reshaped_array, repmat_size);
end
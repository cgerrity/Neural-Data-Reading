function randomizedVector = cgg_procRandomizeChunks(vector, chunkSize)
%CGG_PROCRANDOMIZECHUNKS Summary of this function goes here
%   Detailed explanation goes here
% function randomizedVector = randomizeInChunks(vector, chunkSize)
    % randomizeInChunks - Randomizes the input vector in chunks of size chunkSize
    %
    % Inputs:
    %   vector   - The input vector to randomize
    %   chunkSize - Size of the chunks to randomize individually
    %
    % Output:
    %   randomizedVector - The randomized vector with shuffled chunks
    
    % Initialize the randomized vector as the input vector
    randomizedVector = vector;
    
    % Determine the number of chunks
    numChunks = floor(length(vector) / chunkSize);
    
    % Loop through each chunk and shuffle the chunk
    for i = 1:numChunks
        % Get the indices for the current chunk
        startIdx = (i - 1) * chunkSize + 1;
        endIdx = i * chunkSize;
        
        % Randomize the current chunk
        chunk = randomizedVector(startIdx:endIdx);  % Extract the chunk
        randomizedChunk = chunk(randperm(chunkSize));  % Shuffle the chunk
        randomizedVector(startIdx:endIdx) = randomizedChunk;  % Reassign the shuffled chunk
    end
    
    % Check if there are any leftover elements that don't fit in a chunk
    remainder = mod(length(vector), chunkSize);
    if remainder > 0
        % Randomize the remaining elements (at the end of the vector)
        startIdx = numChunks * chunkSize + 1;
        chunk = randomizedVector(startIdx:end);  % Extract the remaining chunk
        randomizedChunk = chunk(randperm(remainder));  % Shuffle the remaining chunk
        randomizedVector(startIdx:end) = randomizedChunk;  % Reassign the shuffled chunk
    end
end



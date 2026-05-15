function [best_x, best_y] = cgg_findOptimalDivisors(a, b, c)
% FIND_OPTIMAL_DIVISORS Finds x and y such that a is divisible by x*y.
%
% Constraints:
%   1. x <= b
%   2. y <= c
%   3. mod(a, x*y) == 0
%
% Optimization Goals:
%   1. Maximize the product x*y (as large as they can be)
%   2. Minimize the difference between (x/y) and (b/c)
%
% Usage:
%   [x, y] = find_optimal_divisors(120, 10, 15)

    % Initialize tracking variables
    best_x = 1;
    best_y = 1;
    max_product = 0;
    min_ratio_diff = Inf;
    target_ratio = b / c;

    % Loop through all possible values of x within the constraint b
    % Optimization: only check x that are actual divisors of a
    for x = 1:b
        if mod(a, x) == 0
            % Find the maximum possible remaining factor for y
            max_remaining = a / x;
            
            % Loop through all possible values of y within constraint c
            for y = 1:c
                % Check if the product x*y is a divisor of a
                if mod(max_remaining, y) == 0
                    current_product = x * y;
                    current_ratio = x / y;
                    current_diff = abs(current_ratio - target_ratio);
                    
                    % Selection Logic:
                    % Priority 1: Largest product x*y
                    % Priority 2: Closest ratio to b/c (tie-breaker)
                    if current_product > max_product
                        max_product = current_product;
                        min_ratio_diff = current_diff;
                        best_x = x;
                        best_y = y;
                    elseif current_product == max_product
                        if current_diff < min_ratio_diff
                            min_ratio_diff = current_diff;
                            best_x = x;
                            best_y = y;
                        end
                    end
                end
            end
        end
    end
end

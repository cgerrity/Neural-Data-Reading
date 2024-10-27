function cgg_runAttemptFunction(InFunc,AlternateFunc,Attempts)
%CGG_RUNATTEMPTFUNCTION Summary of this function goes here
%   Detailed explanation goes here

PauseMaximum = 10;
IsSuccessful = false;

if ~IsSuccessful
try
    InFunc();
    IsSuccessful = true;
catch
end
end

for aidx = 1:Attempts

    if ~IsSuccessful
    try
        pause(randi(PauseMaximum));
        InFunc();
        IsSuccessful = true;
    catch
    end
    end

end

if ~IsSuccessful
AlternateFunc();
end

for aidx = 1:Attempts

    if ~IsSuccessful
    try
        pause(randi(PauseMaximum));
        InFunc();
        IsSuccessful = true;
    catch
    end
    end

end

if ~IsSuccessful
    InFunc();
end

end


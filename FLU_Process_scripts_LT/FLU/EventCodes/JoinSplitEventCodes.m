function joinedCode = JoinSplitEventCodes(code1, code2, base)

if strcmpi(base, 'decimal')
    code1 = de2bi(code1 - 1, 8);
    code2 = de2bi(code2 - 1, 8);
elseif strcmpi(base, 'binary')
    code1 = bi2de(de2bi(code1) - 1);
    code2 = bi2de(de2bi(code2) - 1);
    code1 = [zeros(1, 8 - length(code1)) code1];
    code2 = [zeros(1, 8 - length(code2)) code2];
else
    error(['Base ' base ' not recognized.']);
end

code1(8) = 0;
code2(8) = 0;

joinedCode = bi2de([code2 code1]);
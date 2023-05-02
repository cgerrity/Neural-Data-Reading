function codeOut = SingleByteCodeFromTwoBytes(codeIn, base)


if strcmpi(base, 'decimal')
    biCode = de2bi(codeIn, 16);
elseif strcmpi(base, 'binary')
    biCode = [zeros(1, 16 - length(codeIn)) codeIn];
else
    error(['Base ' base ' not recognized.']);
end

byte1 = bi2de(biCode(1:8));
byte2 = bi2de(biCode(9:16));

if byte1 == byte2
    codeOut = byte1;
else
    error(['Original 2-byte code ' num2str(codeIn) ' produces ' num2str(byte1) ' and ' num2str(byte2) ' when split, they are not the same.']);
end
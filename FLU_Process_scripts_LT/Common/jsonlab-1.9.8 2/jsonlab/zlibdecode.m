function varargout = zlibdecode(varargin)
%
% output = zlibdecode(input)
%    or
% output = zlibdecode(input,info)
%
% Decompressing a ZLIB-compressed byte-stream to recover the original data
% This function depends on JVM in MATLAB or, can optionally use the ZMat 
% toolbox (http://github.com/fangq/zmat)
%
% Copyright (c) 2012, Kota Yamaguchi
% URL: https://www.mathworks.com/matlabcentral/fileexchange/39526-byte-encoding-utilities
%
% Modified by: Qianqian Fang (q.fang <at> neu.edu)
%
% input:
%      input: a string, int8/uint8 vector or numerical array to store ZLIB-compressed data
%      info (optional): a struct produced by the zmat/lz4hcencode function during 
%            compression; if not given, the inputs/outputs will be treated as a
%            1-D vector
%
% output:
%      output: the decompressed byte stream stored in a uint8 vector; if info is 
%            given, output will restore the original data's type and dimensions
%
% examples:
%      [bytes, info]=zlibencode(eye(10));
%      orig=zlibdecode(bytes,info);
%
% license:
%     BSD 3-clause license, see LICENSE_BSD.txt files for details 
%
% -- this function is part of JSONLab toolbox (http://iso2mesh.sf.net/cgi-bin/index.cgi?jsonlab)
%


if(nargin==0)
    error('you must provide at least 1 input');
end
if(exist('zmat','file')==2 || exist('zmat','file')==3)
    if(nargin>1)
        [varargout{1:nargout}]=zmat(varargin{1},varargin{2:end});
    else
        [varargout{1:nargout}]=zmat(varargin{1},0,'zlib',varargin{2:end});
    end
    return;
elseif(isoctavemesh)
    error('You must install the ZMat toolbox (http://github.com/fangq/zmat) to use this function in Octave');
end
error(javachk('jvm'));

if(ischar(varargin{1}))
    varargin{1}=uint8(varargin{1});
end

input=typecast(varargin{1}(:)','uint8');

buffer = java.io.ByteArrayOutputStream();
zlib = java.util.zip.InflaterOutputStream(buffer);
zlib.write(input, 0, numel(input));
zlib.close();

if(nargout>0)
    varargout{1} = typecast(buffer.toByteArray(), 'uint8')';
    if(nargin>1 && isstruct(varargin{2}) && isfield(varargin{2},'type'))
        inputinfo=varargin{2};
	varargout{1}=typecast(varargout{1},inputinfo.type);
	varargout{1}=reshape(varargout{1},inputinfo.size);
    end
end
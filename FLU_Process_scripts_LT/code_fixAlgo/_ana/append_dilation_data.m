function infoStruct = append_dilation_data(dil,sel, fsample,infoStruct)
% infoStruct = append_dilation_data(SacStructInput,sel, fsample,infoStruct)


if isrow(sel); sel = sel'; end

st = find(diff(sel)==1)+1;
fn = find(diff(sel)==-1);
if fn(1) < st(1); st = [1;st]; end
if fn(end) < st(end); fn = [fn;numel(sel)]; end


dilationPre = cell(numel(st),1);
dilationDuring = cell(numel(st),1);
dilationPost = cell(numel(st),1);

for ievent=1:numel(st)
    dilationPre{ievent} = dil(max(1, st(ievent) -200 / (1000/fsample)):st(ievent)-1);
    dilationDuring{ievent} = dil(st(ievent) : fn(ievent));
    dilationPost{ievent} = dil(min([fn(ievent)+1,end]):min(fn(ievent)+200/(1000/fsample):end));
end


infoStruct.DilationPre = dilationPre;
infoStruct.DilationDuring = dilationDuring;
infoStruct.DilationPost = dilationPost;


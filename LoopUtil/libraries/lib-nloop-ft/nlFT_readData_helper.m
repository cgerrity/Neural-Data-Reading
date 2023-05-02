function data = nlFT_readData_helper( indir, wantnative, ...
  header, firstsample, lastsample, chanidxlist )

% function data = nlFT_readData_helper( indir, wantnative, ...
%   header, firstsample, lastsample, chanidxlist )
%
% This probes the specified directory using nlIO_readFolderMetadata(), and
% reads all appropriate signal data into a Field Trip data matrix.
%
% This may either promote data to double or keep it as its native type,
% depending on "wantnative".
%
% NOTE - This returns monolithic data (a 2D matrix), not epoched data.
% NOTE - This requires all selected banks to have the same sampling rate and
% number of samples!
%
% This calls nlFT_testWantChannel() and nlFT_testWantBank() and only saves
% channels that are wanted. By default all channels and banks are wanted;
% use nlFT_selectChannels() to change this.
%
% If directory probing fails, an error is thrown.
%
% "indir" is the directory to process.
% "wantnative" is true to store native-format data and false to promote to
%   double-precision floating-point.
% "header" is the Field Trip header associated with this directory.
% "firstsample" is the index of the first sample to read (starting at 1).
% "lastsample" is the index of the last sample to read.
% "chanidxlist" is a vector containing Field Trip channel indices to read.
%
% "data" is the resulting 2D data matrix.

% Magic constants.
foldername = 'datafolder';
memchans = nlFT_getMemChans();

% Read the folder metadata.
[ isok foldermeta ] = nlIO_readFolderMetadata( ...
  struct([]), foldername, indir, 'auto' );

if ~isok
  error(sprintf( ...
    'nlIO_readFolderMetadata() didn''t find anything in "%s".', indir ));
else
  % We only care about this particular folder's metadata.
  bankmeta = foldermeta.folders.(foldername).banks;

  % Iterate through banks and channels, building a channel list.
  % NOTE - Do this in sorted order for consistent numbering.

  iteratebanklist = struct();
  globalchancount = 0;
  filteredglobalchancount = 0;
  chanindexlut = struct();

  banknames = sort( fieldnames(bankmeta) );

  for bidx = 1:length(banknames)
    thisbankname = banknames{bidx};
    thisbankmeta = bankmeta.(thisbankname);

    thischanlist = thisbankmeta.channels;
    thiscount = thisbankmeta.sampcount;
    thistype = thisbankmeta.banktype;

    % Proceed if this is a bank we want to process at all.
    % We've already checked for size and rate consistency when reading the
    % header.

    if nlFT_testWantBank(thisbankname, thistype)

      % Build and filter the list of prospective channel names.

      newchanlist = [];
      newchanqty = 0;

      for cidx = 1:length(thischanlist)
        thischanidx = thischanlist(cidx);
        thischanname = nlFT_makeFTName( thisbankname, thischanidx );

        if nlFT_testWantChannel(thischanname)

          % This channel passes our filtering, so it's in the header.
          % That doesn't mean we'll necessarily iterate over it, though.
          % Check the channel index list for that.

          globalchancount = globalchancount + 1;

          if ismember(globalchancount, chanidxlist)
            % Add to the lookup table of output channel IDs.
            % NOTE - the list of channel labels gets filtered too, so this
            % should be the filtered global count, not the unfiltered global
            % count.
            filteredglobalchancount = filteredglobalchancount + 1;
            chanindexlut.(thischanname) = filteredglobalchancount;

            % Add to the iterated channel list for this bank.
            newchanqty = newchanqty + 1;
            newchanlist(newchanqty) = thischanidx;
          end

        end
      end

      % If we have any channels left, add this bank's channels.

      if length(newchanlist) > 0
        iteratebanklist.(thisbankname) = struct( ...
          'chanlist', newchanlist, 'samprange', [ firstsample lastsample ] );
      end

    end
  end

  % Construct the project-level channel list.
  iteratelist = struct(foldername, iteratebanklist);


  % Iterate through the project-level channel list, adding data series.

  % FIXME - We're ignoring the result-passing mechanism and are instead
  % modifying the "data" variable directly. This greatly reduces copying.

  data_chan_count = 0;
  clear data;

  if wantnative
    dummyval = nlIO_iterateChannels( foldermeta, iteratelist, memchans, ...
      @nlFT_readData_helper_native );
  else
    dummyval = nlIO_iterateChannels( foldermeta, iteratelist, memchans, ...
      @nlFT_readData_helper_double );
  end
end


%
% Helper Functions

% NOTE - These are nested, rather than local, so that they can access the
% parent function's "data" variable.

% FIXME - We're ignoring the result-passing mechanism and are instead
% modifying the "data" variable directly. This greatly reduces copying.

% NOTE - We don't need to crop to the selected span here; the channel list
% already specified the range of samples we were interested in, so that's
% all that was read.


% Processing function for reading data as double-precision floating-point.

function resultval = nlFT_readData_helper_double( ...
  metadata, folderid, bankid, chanid, ...
  wavedata, timedata, wavenative, timenative )

  % Get Field Trip's channel index for this channel.
  % We aren't necessarily reading channels in-order.

  thischanname = nlFT_makeFTName(bankid, chanid);
  channelindex = chanindexlut.(thischanname);


  % If this is sparse (event) data, promote it to continuous.
  % NOTE - We aren't using continuous timenative or timecooked, so don't
  % promote them.

  bankmeta = metadata.folders.(folderid).banks.(bankid);

  if contains(bankmeta.banktype, 'event')
    % NOTE - We _do_ need to specify the truncated sample range here.
    wavenative = nlUtil_sparseToContinuous( ...
      timenative, wavenative, [firstsample lastsample] );

    % We only need wavenative and wavedata.
    % NOTE - Originally we left "logical" types intact, but that caused
    % problems when reading data with mixed types.
    wavedata = double(wavenative);
  end


  % NOTE - We don't need to isolate the requested span; that's already done.


  % Store this slice.

  data_length = length(wavedata);

  % This works even if data hasn't been initialized, and forces the correct
  % geometry and type.
  % 2D data is stored as (Nchans*Nsamples).

  data( channelindex, 1:data_length ) = wavedata;


  % Store a dummy result, since we aren't using it.
  resultval = NaN;

end


% Processing function for reading data in native format.

function resultval = nlFT_readData_helper_native( ...
  metadata, folderid, bankid, chanid, ...
  wavedata, timedata, wavenative, timenative )

  % Get Field Trip's channel index for this channel.
  % We aren't necessarily reading channels in-order.

  thischanname = nlFT_makeFTName(bankid, chanid);
  channelindex = chanindexlut.(thischanname);


  % If this is sparse (event) data, promote it to continuous.
  % NOTE - We aren't using continuous timenative or timecooked, and we aren't
  % using wavedata, so don't promote them.

  bankmeta = metadata.folders.(folderid).banks.(bankid);

  if contains(bankmeta.banktype, 'event')
    % NOTE - We _do_ need to specify the truncated sample range here.
    wavenative = nlUtil_sparseToContinuous( ...
      timenative, wavenative, [firstsample lastsample] );

    % We only need wavenative.
  end


  % NOTE - We don't need to isolate the requested span; that's already done.


  % Store this slice.

  data_length = length(wavenative);

  % This works even if data hasn't been initialized, and forces the correct
  % geometry and type.
  % 2D data is stored as (Nchans*Nsamples).

  data( channelindex, 1:data_length ) = wavenative;


  % Store a dummy result, since we aren't using it.
  resultval = NaN;

end


% Done (parent function).

end


%
% This is the end of the file.

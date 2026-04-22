function [varData]=matGetVariable(fileID,whichVariable,nElements,startOffset)


% varData=matGetVariable(fileID,whichVariable,nElements,startOffset);
%
% Returns a portion of a specified variable from a version 4 (?) MAT file.
% The MAT file (fileID) can be specified by name (string) or by an open fid.
% The variable is specified by its name, a string (whichVariable).
% nElements and startOffset specify the length and offset of the 
% desired portion of the variable's data.
%
% BUGS:-  Will only put data into a 1-D array at the moment. This is easy to generalize and should be but hasn't been yet.
%      -  Can only deal with 5 types of MATLAB variable, and only those
%           with 0, 1, or 2 dimensions.
%      -  Does matlab always save with the same machineformat? Machine format not yet fixed.
%      -  DOES NOT DEAL WITH COMPLEX NUMBERS YET
%
% by cPbL@alum.mit.edu and Robert M Barrington Leigh, 2000 August 23

% OPTIONAL FORMS FOR FIRST ARGUMENT
if ~exist('fileID','var') | isempty(fileID)% FOR DEBUGGING
   [filename,pathname] = uigetfile('.mat', 'Choose a .mat file to open');
   fileID=[ pathname filename]
end%if
if ischar(fileID)
   fid=fopen(fileID,'r'); % Need to fix machine format
else
   fid=fileID;
end%if

% IF NO VARIABLE CHOSEN, GIVE A LIST OF THE VARIABLES:
if nargin ==1,
   varNames=matGetVarInfo(fileID);
   varNames'
	if ischar(fileID)
   		fclose(fid);
	end%if
   return
end%if

% BEGIN MAJOR LOOP OVER ALL EXISTING VARIABLES IN FILE
while (~feof(fid))
   
   [varName,varType,varRows,varCols,varImag,varSize]=matReadHeader(fid);
   if isnan(varName)%  File was not in a readable format.
      disp('Cannot read single variables from this file.');
      varData=NaN;
      return;
   end%if   
   if varName==-1 % EOF HAS OCCURRED
      break;  
   end%if
   
   if strcmp(varName,whichVariable), % THIS IS THE VARIABLE WE WANT
      if nargin < 3,  % CALLER WANTS ALL THE DATA
         nElements=varRows*varCols;
      end%if
      if nargin <4 % CALLER DIDN'T SPECIFIY START OFFSET
         startOffset=0;
      elseif startOffset>max(varRows*varCols-1,0)
         error('The start offset is too large.');
      end%if
      fseek(fid,(startOffset)*varSize,'cof');
      varData=fread(fid,min([nElements varRows*varCols-startOffset]),varType);
      if (~isempty(findstr(varType,'char')))
         varData=char(varData)';
      end%if
	if ischar(fileID)
   		fclose(fid);
	end%if
      return;
   else % THIS IS NOT THE VARIABLE WE WANT!
      fseek(fid,varCols*varRows*varSize,'cof');
   end%if
end%while LOOP OVER EXISTING VARIABLES

fileID
if ischar(fileID)
   fclose(fid);
end%if



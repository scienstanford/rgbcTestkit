function [ im ] = loadRaw( filename )
%READRAW Reads the raw image data 


if ~strcmpi(filename(end-3:end),'.raw')
    error('Filename should end in .raw')
end

sensorsize = [4224, 3136]; 

fid = fopen(filename, 'r');
im = fread(fid, sensorsize, 'uint8');
fclose(fid); clear fid;

im = im';
end


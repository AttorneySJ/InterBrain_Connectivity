function readNreset(trig,trig2compare,varargin)
if nargin == 2
    IDX = 1;
else
    IDX = varargin{1};
end
while io64(trig.io.obj, trig.io.address(IDX))~=trig2compare;end
io64(trig.io.obj, trig.io.address(IDX),0)
disp('connected!')
end

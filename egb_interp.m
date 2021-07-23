function data = egb_interp(data, chanlocs, goodchans, method)

if nargin<4
    method = 'nearest';
end

badchans = setdiff(1:size(data,1), find(goodchans));

[xbad ,ybad]  = pol2cart([chanlocs( badchans).theta],[chanlocs( badchans).radius]);
[xgood,ygood] = pol2cart([chanlocs(goodchans).theta],[chanlocs(goodchans).radius]);
xbad = xbad';
ybad = ybad';
xgood = xgood';
ygood = ygood';

if strcmp(method,'nearest')
    parfor t=1:(size(data,2)*size(data,3)) % 
        if isa(data(:,t),'double')
            td = data(:,t);
        else
            td = double(data(:,t));
        end
        F = TriScatteredInterp(xgood, ygood, td(goodchans), 'nearest');
        td(badchans) = F(xbad, ybad);
        if isa(data(:,t),'double')
            data(:,t) = td;
        else
            data(:,t) = single(td);
        end
    end
elseif strcmp(method,'cubic')
    dt = DelaunayTri(xgood,ygood);
    dtt = dt.Triangulation;
    if isempty(dtt)
      warning(message('MATLAB:griddata:EmptyTriangulation'));
      return
    end
    tri = dt.Triangulation;
    siz = size(xbad);
    ti = dt.pointLocation(xbad(:),ybad(:));
    ti = reshape(ti,siz);

    parfor t=1:(size(data,2)*size(data,3)) % 
        td = data(:,t);
        td(badchans) = cubicmx(xgood,ygood,td(goodchans),xbad,ybad,tri,ti);
        data(:,t) = td;
    end
else
    error('Unknown method for interpolation.');
end



    
    
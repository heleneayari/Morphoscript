function ImageWindowed = windowing(Image)

Image = double(Image);
ImageSize = size(Image);

v = zeros(ImageSize);

if length(ImageSize) == 3
    v(1, :, :) = v(1, :, :) + Image(1, :, :) - Image(end, :, :);
    v(end, :, :) = v(end, :, :) - Image(1, :, :) + Image(end, :, :);
    
    v(:, 1, :) = v(:, 1, :) + Image(:, 1, :) - Image(:, end, :);
    v(:, end, :) = v(:, end, :) - Image(:, 1, :) + Image(:, end, :);
    
    v(:, :, 1) = v(:, :, 1) + Image(:, :, 1) - Image(:, :, end);
    v(:, :, end) = v(:, :, end) - Image(:, :, 1) + Image(:, :, end);
    
    f1 = repmat(cos(2 * pi * ((reshape(1 : ImageSize(1), [ImageSize(1) 1 1])) - 1)/ ImageSize(1)), 1, ImageSize(2), ImageSize(3));
    f2 = repmat(cos(2 * pi * ((reshape(1 : ImageSize(2), [1 ImageSize(2) 1])) - 1)/ ImageSize(2)), ImageSize(1), 1, ImageSize(3));
    f3 = repmat(cos(2 * pi * ((reshape(1 : ImageSize(3), [1 1 ImageSize(3)])) - 1)/ ImageSize(3)), ImageSize(1), ImageSize(2), 1);
    
    f1(1, 1, 1) = 0;
    s = real(ifftn(fftn(v) * 0.5 ./ (3 - f1 - f2 - f3)));
    
elseif length(ImageSize) == 2
    v(1, :) = v(1, :) + Image(1, :) - Image(end, :);
    v(end, :) = v(end, :) - Image(1, :) + Image(end, :);
    
    v(:, 1) = v(:, 1) + Image(:, 1) - Image(:, end);
    v(:, end) = v(:, end) - Image(:, 1) + Image(:, end);
    
    f1 = repmat(cos(2 * pi * ((reshape(1 : ImageSize(1), [ImageSize(1) 1])) - 1)/ ImageSize(1)), 1, ImageSize(2));
    f2 = repmat(cos(2 * pi * ((reshape(1 : ImageSize(2), [1 ImageSize(2)])) - 1)/ ImageSize(2)), ImageSize(1), 1);
    
    f1(1, 1) = 0;
    s = real(ifftn(fftn(v) * 0.5 ./ (2 - f1 - f2)));

elseif length(ImageSize) == 1
    
    v(1) = v(1) + Image(1) - Image(end);
    v(end) = v(end) - Image(1) + Image(end);
     
    f1 = repmat(cos(2 * pi * ((reshape(1 : ImageSize(1), [ImageSize(1)])) - 1)/ ImageSize(1)), 1);
     
    f1(1) = 0;
    s = real(ifftn(fftn(v) * 0.5 ./ (1 - f1)));
       
else
    error('function only works for 1, 2, and 3D images');
end

ImageWindowed = Image - s;


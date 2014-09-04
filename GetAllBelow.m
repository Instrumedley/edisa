%extracts all modules with a score lower than the threshold,
%which are bigger than the given size (number).
function b = GetAllBelow(results, threshold, number)

b = [];
b_temp = find(cell2mat(results(:,3))<threshold);
counter=1;
for i = 1:length(b_temp)
    if length(results{b_temp(i),1}) >=number
        b(counter)=b_temp(i);
        counter=counter+1;
    end
end
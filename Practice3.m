% Guillermo Rodriguez Plazas: 100429149
% Gonzalo Prats Juliani: 100429904

close all;
clear;
clc;

lifeExpData = xlsread('dataPr3.xlsx', 'B1:BS186'); %Life expectancy
babiesWomanData = xlsread('dataPr3.xlsx', 'HG1:JX186'); %Babies per woman
[waste, countryList, waste2] = xlsread('dataPr3.xlsx', 'A3: A186'); %Obtain the list of countries

linRegVal=zeros(7,2);
yearselection = 1950;
for index=1:7 
    
    %determine position of date
    col=1;
    pos_yearselection=yearselection;
    val=0;
    while(val==0)
        if (pos_yearselection == lifeExpData(1,col))
            initpos=col;
            val=1;
        else
            col=col+1;
        end
    end

    %Matrix of Life Expectancy data
    lifeDataMat=[];
    for i = 0:9
        for j = 2: 185
            lifeDataMat = [lifeDataMat lifeExpData(j,initpos)];
        end
        initpos = initpos + 1;
    end
    lifeDataMat = transpose(lifeDataMat);

    %Matrix of BabiesWomanData reordered
    initpos=col;
    babyWoMat=[];
    for i = 0:9
        for j = 2: 185
            babyWoMat = [babyWoMat babiesWomanData(j,initpos)];
        end
        initpos = initpos + 1;
    end
    babyWoMat = transpose(babyWoMat);

    %Apply least Squares
    [m, n]=leastSquares(lifeDataMat,babyWoMat);
    
    linRegVal(index,1)=m;
    linRegVal(index,2)=n;

yearselection=yearselection+10;
end %Index end

maxError = 0;
maxErrorMat = [];
totalError = 0;
errorSum = [];
for index = 1: 7    
    for i = 1: 184
       for j = (1+(index - 1)*10): (9+(index-1)*10)
            m = (linRegVal(index, 1))*(-1);
            n = (linRegVal(index, 2))*(-1);
            numerator = abs(babiesWomanData(i+1,j) + m * lifeExpData(i+1,j) + n);
            denominator = sqrt(m.^2 + 1);
            error = numerator/denominator;
            totalError = totalError + error;
            if error > maxError
                maxError = error;
                maxErrorMat(index, 1) = error;
                maxErrorMat(index, 2) = 1950 + (j - 1);
                maxErrorMat(index, 3) = i;
                
            end
       end
    end
    errorSum(index,1) = totalError;
    totalError = 0;
    maxError = 0;
end


%Question c)
decades=[];
for i=1:7
    val_a=[];
    val_a=[val_a linRegVal(i,1)];
    decades=[decades i];
end
val_a=transpose(val_a);
decades=transpose(decades);
[c1,c0]=leastSquares(decades,val_a);

for i=1:7
    val_b=[];
    val_b=[val_b linRegVal(i,2)];
end
val_b=transpose(val_b);
[c3,c2]=leastSquares(decades,val_b);

[c5,c4]=leastSquares(decades,errorSum);
cmat=[c0 c1 c2 c3 c4 c5];

%Solutionprint
fprintf('\nSOLUTIONS\na) x = Life Expectancy and y = Babies per Woman\n\nb) a and b correspond to form: y=ax+b, e=Total error and C=Country and Y=Year where worst error happened:');
for index=1:7
   fprintf('\nDecade %d: \ta = %.3f \tb= %.3f \te= %.3f ',1950+(index-1)*10,linRegVal(index,1),linRegVal(index,2),errorSum(index, 1)); 
   countryListName = string(countryList(maxErrorMat(index, 3), 1));
   fprintf('\teMax= %.3f \tC= %s \tY= %d', maxErrorMat(index, 1), countryListName, maxErrorMat(index, 2));
end
fprintf('\n\nc) The values for c are: ');
for c=1:5
    fprintf('%.5f ',cmat(1,c));
end
fprintf('\n\nQuestions: \n1) See Figure 2 (c´s representation): \nWe can observe that the slope and the intercept appear to have little variation. Observing the error interpolation, a clear descending tendency is recognised. This suggests that data becomes more predictable through the years. \nSee Figure 1:\nIn terms of the variables we observe that as the years pass, the slope of the tendency between child birth and life expectancy increases, getting steeper. ');
fprintf('\n\n2) Worst Errors through decades by country and year:\nDecade 1950: North Korea (1951). Such deviation from the model coincides with the Korean War (1950-1953). 500.000 deaths ocurred in the North Korean side (decreasing massively life expectancy) and 170.000 in the South Korean. \n'); 
fprintf('Decade 1960: China (1961). It might be related to the Great Chinese Famine (1959-1961), where due a lack of food, significantly less children were born and people died at a younger age because of starvation\n');
fprintf('Decade 1970: Cambodia (1978). The Cambodian-Vietnamese War (1978-1989) starts with a very bloody first year, which decreased life expectancy drastically. Moreover, the war led to a famine, which caused less newborns and more early deaths.\n');
fprintf('Decade 1980: Oman (1886). There is no specific reason besides a growth period. An unusual economic growth combined with an investement in universities, resulted in an extrordnary increase in life expectancy and did child birth rates.\n');
fprintf('Decade 1990: Rwanda (1994). Corresponding to the Rwandan Genocide (against the Tusi population), almost 1.000.000 people died, reducing drastically life expectancy and child birth rates due to the terror clima,\n');
fprintf('Decade 2000: Timor Leste (2001). The year of the first parliament election, marks s period of growth as a country. The development and hope in sight the unusual growth in child birth rates and Life expectancy.\n');
fprintf('Decade 2010: Haiti (2010). This deviation from the model was caused by the 2010 earthquake, one of the greatest of humanity with a magnitude of 7. The 300.000 fatalities altered the life expectancy rates.\n');

%Plot Relation
x=linspace(1,100,100);
for i=1:7    
    y=x*linRegVal(i,1) + linRegVal(i,2);
    plot(x,y,'DisplayName',num2str(1950+(i-1)*10));
    grid;
    legend;
    xlabel('Life Expectancy [Years]');
    ylabel('Children per Woman');
    hold on;
end

%Plot C
figure;
tag=['a' 0 'b' 0 'e'];
x=linspace(1,7,7);
for i=1:2:6    
    y=x*cmat(i+1) + cmat(i);
    plot(x,y,'DisplayName',tag(i));
    grid;
    legend;
    xlabel('Decade');
    ylabel('Data');
    hold on;
end


%Function
function [m, n] = leastSquares(matA, matB)
    newmatrix = [matA ones(size(matA, 1), 1)];
    x = (inv(transpose(newmatrix)*newmatrix))*(transpose(newmatrix)*matB);
    m = x(1, 1);
    n = x(2, 1);
end


%% 针对excel格式

[num,txt,raw]=xlsread('D:\武大测绘\wifi待测点\WiFi(5).csv') ;
M(:,1) =txt(:,2);
I(:,1)=num(:,3);
[r,c] = size(M);    % 读取行r、列c
P=str2double(M{1,1});

for i = 1:r        % 建立for循环嵌套
    sum1=0;
    sum2=0;
    sigma=0;
    for j = 1:r
        if M{i,1}==M{j,1}
         sum1=sum1+1;
         sum2=sum2+I(j,1);
         MAC{i,1}=M{i,1};
         Intensity(i,1)=sum2/sum1;   
         s1=((sum2/sum1)-I(j,1))^2;
         sigma=(sigma+s1)/sum1;
        end
    end
    if sum1<=10||sigma>3
        
             MAC(i,:)=[];
         Intensity(i,:)=[]; 
         
    end 
    [o,c] = size(Intensity); %除去信号出现次数小于10或者方差大于3的wifi信号
    for g=i:r-o-1
        MAC(g,1)=MAC(g+1,1);
         Intensity(g,1)=Intensity(g+1,1); 
    end
    
end

fid=fopen('D:\武大测绘\change.txt','w');  
fprintf(fid,'input\n');
fprintf(fid,'0.00  0.00  \n');
for i=1:50
    fprintf(fid,'%s%10.f\n',MAC{i,1},Intensity(i,1));
end
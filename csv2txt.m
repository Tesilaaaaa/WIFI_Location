%% ���excel��ʽ

[num,txt,raw]=xlsread('D:\�����\wifi�����\WiFi(5).csv') ;
M(:,1) =txt(:,2);
I(:,1)=num(:,3);
[r,c] = size(M);    % ��ȡ��r����c
P=str2double(M{1,1});

for i = 1:r        % ����forѭ��Ƕ��
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
    [o,c] = size(Intensity); %��ȥ�źų��ִ���С��10���߷������3��wifi�ź�
    for g=i:r-o-1
        MAC(g,1)=MAC(g+1,1);
         Intensity(g,1)=Intensity(g+1,1); 
    end
    
end

fid=fopen('D:\�����\change.txt','w');  
fprintf(fid,'input\n');
fprintf(fid,'0.00  0.00  \n');
for i=1:50
    fprintf(fid,'%s%10.f\n',MAC{i,1},Intensity(i,1));
end
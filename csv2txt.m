%% ���excel��ʽ

[num,txt,raw]=xlsread('D:\�����\wifi�����\WiFi(5).csv') ;
M(:,1) =txt(:,2);
I(:,1)=num(:,3);
[r,c] = size(M);    % ��ȡ��r����c
P=str2double(M{1,1});
for i = 1:r        % ����forѭ��Ƕ��
    sum1=0;
    sum2=I(i,1);
    for j = 1:r
        if M{i,1}==M{j,1}
         sum1=sum1+1;
         sum2=sum2+I(j,1);
         MAC{i,1}=M{i,1};
         Intensity(i,1)=sum2/sum1;        
        end
    end
end

fid=fopen('D:\�����\change.txt','w');  
fprintf(fid,'input\n');
fprintf(fid,'0.00  0.00  \n');
for i=1:30
    fprintf(fid,'%s%10.f\n',MAC{i,1},Intensity(i,1));
end
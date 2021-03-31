clear,clc;

%��������RISS�ļ���ʽ�Ľṹ��
data = struct('X',NaN,'Y',NaN,'S',NaN,'time',NaN,...
    'signal',NaN,'intensity',NaN);
eg = struct('X',NaN,'Y',NaN,'S',NaN,'time',NaN,...
    'signal',NaN,'intensity',NaN);

%% ���ݶ�ȡ��˵��
%��ȡ�����ļ�
fid1=fopen('D:\�����\Train_all3.txt','r');
fid2=fopen('D:\�����\change.txt','r');

head_lines = 0;
while 1
    head_lines = head_lines+1;
    line = fgetl(fid1);
    answer = strfind(line,'END');
    if ~isempty(answer)
        break
    end
end
noeph = -1;
while 1
    noeph = noeph+1;
    line = fgetl(fid1);
    if line == -1
        break
    end
end
noeph = noeph/31;% pseuo random code
frewind(fid1);
for l = 1:head_lines
    line = fgetl(fid1);
end
   
for i = 1:noeph
    line = fgetl(fid1); 
     data(i,1).x = str2num(line(1:6));  %��һ�� ����
     data(i,1).y = str2num(line(7:11));
     for j=2:31
     line = fgetl(fid1);              %ʣ��30��Ϊÿ��������RSSI
     data(i,j).singal = line(1:18);
     data(i,j).intensity = str2num(line(19:22));
     end
end
status = fclose(fid1);

head_lines = 0;
while 1
    head_lines = head_lines+1;
    line = fgetl(fid2);
    answer = strfind(line,'input');
    if ~isempty(answer)
        break
    end
end
noeph = -1;
while 1
    noeph = noeph+1;
    line = fgetl(fid2);
    if line == -1
        break
    end
end
noeph = noeph/51;% pseuo random code
frewind(fid2);
for l = 1:head_lines
    line = fgetl(fid2);
end
for i = 1:noeph
    line = fgetl(fid2); 
     eg(i,1).x = str2num(line(1:6));  %��һ�� ����
     eg(i,1).y = str2num(line(7:11));
     for j=2:51
     line = fgetl(fid2);              %ʣ��30��Ϊ����������RSSI
     eg(i,j).singal = line(1:18);
     eg(i,j).intensity = str2num(line(25:27));
     end
     
end
status = fclose(fid2);

%% KNN�㷨�����ݴ���
%����Ŀ�����ָ�ƿ��ƥ��� ��ŷʽ����
d=[];
%�����е����ݽ��й�һ�������Ա���������ͬ�ֻ����������������
egmax=eg(1,2).intensity;
for m=2:51
    if egmax>=eg(1,m).intensity
        egmax=egmax;
    elseif egmax<eg(1,m).intensity
        egmax=eg(1,m).intensity;
    end
end


for i=1:107
    datamax(i,1)=data(i,2).intensity;
    for j=2:31
    if datamax(i,1)>=data(i,j).intensity
        datamax(i,1)=datamax(i,1);
    elseif datamax(i,1)<data(i,j).intensity
        datamax(i,1)=data(i,j).intensity;
    end
    end
end

for m=2:51
    for i=1:107
    for j=2:31
       
   if data(i,j).singal==eg(1,m).singal
       d((m-1),(j-1),i)=abs((data(i,j).intensity/datamax(i,1))-(eg(1,m).intensity/egmax));
   else
       d((m-1),(j-1),i)=1;
   end
    end
    end
end

%��ȡ117���������ʵ����ƥ���
y=sum(sum(d(:,:,:)));
for i=1:107
   c(i,1)=y(1,1,i) ;
   c(i,2)=data(i,1).x;
   c(i,3)=data(i,1).y;
end

%��������ƥ���
K_singal=sortrows(c,1);
    
sum=K_singal(1,1)+K_singal(2,1)+K_singal(3,1)+K_singal(4,1);

%����KNN�㷨��˼�� ����K=4
%���ź�ǿ��ΪȨ�����λ����
KNN_X=(K_singal(1,1)*K_singal(1,2)+K_singal(2,1)*K_singal(2,2)+K_singal(3,1)*K_singal(3,2)+K_singal(4,1)*K_singal(4,2))/sum;
KNN_Y=(K_singal(1,1)*K_singal(1,3)+K_singal(2,1)*K_singal(2,3)+K_singal(3,1)*K_singal(3,3)+K_singal(4,1)*K_singal(4,3))/sum;

dxy=sqrt((eg(1,1).x-KNN_X)^2+(eg(1,1).y-KNN_Y)^2);

%% ������
fid=fopen('D:\�����\result.txt','w');  
fprintf(fid,'ʵ���X����   ʵ���Y����\n');
fprintf(fid,'%10.3f   %10.3f\n',eg(1,1).x ,eg(1,1).y);
fprintf(fid,'wifi��λX����   wifi��λY����\n');
fprintf(fid,'%10.3f   %10.3f\n',KNN_X ,KNN_Y );
fprintf(fid,'��λƫ��\n');
fprintf(fid,'%10.3f \n',dxy);

p=imread('D:\�����\������¥.png'); % ����ͼƬ
imshow(p); % ��ʾͼƬ
hold on; % ���ֵ�ǰ��ʾ��ͼƬ
x0=562;y0=103; % 
TrueX=(-19.5)*eg(1,1).x+x0;
TrueY=21*eg(1,1).y+y0;%����ת��
changeX=(-19.5)*KNN_X+x0;
changeY=21*KNN_Y+y0;%����ת��
plot(TrueX,TrueY,'p'); % ��ʵλ�� 
plot(changeX,changeY,'x'); % ��λλ�� 
hold off
    
    
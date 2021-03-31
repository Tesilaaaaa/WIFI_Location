clear,clc;

%建立符合RISS文件格式的结构体
data = struct('X',NaN,'Y',NaN,'S',NaN,'time',NaN,...
    'signal',NaN,'intensity',NaN);
eg = struct('X',NaN,'Y',NaN,'S',NaN,'time',NaN,...
    'signal',NaN,'intensity',NaN);

%% 数据读取及说明
%读取数据文件
fid1=fopen('D:\武大测绘\Train_all3.txt','r');
fid2=fopen('D:\武大测绘\change.txt','r');

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
     data(i,1).x = str2num(line(1:6));  %第一行 坐标
     data(i,1).y = str2num(line(7:11));
     for j=2:31
     line = fgetl(fid1);              %剩下30行为每个坐标点的RSSI
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
     eg(i,1).x = str2num(line(1:6));  %第一行 坐标
     eg(i,1).y = str2num(line(7:11));
     for j=2:51
     line = fgetl(fid2);              %剩下30行为待测坐标点的RSSI
     eg(i,j).singal = line(1:18);
     eg(i,j).intensity = str2num(line(25:27));
     end
     
end
status = fclose(fid2);

%% KNN算法及数据处理
%计算目标点与指纹库的匹配度 即欧式距离
d=[];
%对所有的数据进行归一化处理，以便于消除不同手机测量所带来的误差
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

%获取117个点相对于实验点的匹配度
y=sum(sum(d(:,:,:)));
for i=1:107
   c(i,1)=y(1,1,i) ;
   c(i,2)=data(i,1).x;
   c(i,3)=data(i,1).y;
end

%升序排列匹配差
K_singal=sortrows(c,1);
    
sum=K_singal(1,1)+K_singal(2,1)+K_singal(3,1)+K_singal(4,1);

%采用KNN算法的思想 采用K=4
%以信号强度为权计算点位坐标
KNN_X=(K_singal(1,1)*K_singal(1,2)+K_singal(2,1)*K_singal(2,2)+K_singal(3,1)*K_singal(3,2)+K_singal(4,1)*K_singal(4,2))/sum;
KNN_Y=(K_singal(1,1)*K_singal(1,3)+K_singal(2,1)*K_singal(2,3)+K_singal(3,1)*K_singal(3,3)+K_singal(4,1)*K_singal(4,3))/sum;

dxy=sqrt((eg(1,1).x-KNN_X)^2+(eg(1,1).y-KNN_Y)^2);

%% 结果输出
fid=fopen('D:\武大测绘\result.txt','w');  
fprintf(fid,'实验点X坐标   实验点Y坐标\n');
fprintf(fid,'%10.3f   %10.3f\n',eg(1,1).x ,eg(1,1).y);
fprintf(fid,'wifi定位X坐标   wifi定位Y坐标\n');
fprintf(fid,'%10.3f   %10.3f\n',KNN_X ,KNN_Y );
fprintf(fid,'定位偏差\n');
fprintf(fid,'%10.3f \n',dxy);

p=imread('D:\武大测绘\国重四楼.png'); % 调入图片
imshow(p); % 显示图片
hold on; % 保持当前显示的图片
x0=562;y0=103; % 
TrueX=(-19.5)*eg(1,1).x+x0;
TrueY=21*eg(1,1).y+y0;%坐标转化
changeX=(-19.5)*KNN_X+x0;
changeY=21*KNN_Y+y0;%坐标转化
plot(TrueX,TrueY,'p'); % 真实位置 
plot(changeX,changeY,'x'); % 定位位置 
hold off
    
    
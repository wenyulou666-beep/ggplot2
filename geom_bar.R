#柱状图进阶之调色
library(ggplot2)
library(gcookbook)
data("cabbage_exp")
data("pg_mean")
data("BOD")

#----------------------------------------------------------------------
#1.1
pg_mean <- pg_mean
ggplot(pg_mean,aes(x=group,y=weight))+geom_bar(stat="identity")
#stat="count" 是默认，y=x的出现次数
#stat="identity",表示一个x对应一个y

#对于连续型变量
#没有的数据会变成空格
BOD <- BOD
ggplot(BOD,aes(x=Time,y=demand))+geom_bar(stat="identity")
#去掉空格，把连续变量x转换成分类变量
ggplot(BOD,aes(x=factor(Time),y=demand))+geom_bar(stat="identity")


#------------------------------------------------------------------
#1.2 修改柱状图的描边color和填充fill
ggplot(pg_mean,aes(x=group,y=weight))+
  geom_bar(stat="identity",fill="lightblue",color="red")

#也可以通过分组变量设置颜色，fill=分组变量或 color=分组变量
#折线图中linestyle也可以
ggplot(cabbage_exp,aes(x=Date,fill = Cultivar))+
  geom_bar(position="dodge") #无y无stat dodge分开
#position="stack"堆积 identity不调整(重叠) fll按比例堆积 

#自定义颜色
RColorBrewer::display.brewer.all()#调色盘
ggplot(cabbage_exp,aes(x=Date,fill = Cultivar))+
  geom_bar(position="dodge",color="black")+
  scale_fill_brewer("Pastel1")

#注意:如果类别变量的组合有任何缺失,则该栏缺失,相邻栏扩展以填充空间
ce <- cabbage_exp[1:5,]
ggplot(ce,aes(x=Date,y=Weight,fill = Cultivar))+
  geom_bar(position="dodge",color="black",stat="identity")+
  scale_fill_brewer("Pastel1")

#实际中把不存在的值变为0或NA
ce_NA <- cabbage_exp
ce_NA$Weight[6] <- 0
ggplot(ce_NA,aes(x=Date,y=Weight,fill = Cultivar))+
  geom_bar(position="dodge",color="black",stat="identity")+
  scale_fill_brewer("Pastel1")

#修改颜色的技巧
#注意:geom_bar()在使用 stat = "identity" ,
#默认位置是 position = "dodge"（并排）
data("uspopchange")
upc <- subset(uspopchange,rank(Change)>40)

ggplot(upc,aes(x=Abb,y=Change,fill=Region))+
  geom_bar(stat="identity",color="black")+
  scale_fill_manual(values = c("lightblue","orange"))+
  xlab("State")

#此外还使用reorder()，将条形从低到高排序
#reorder(1,2),1按照2的大小来排序
ggplot(upc,aes(x=reorder(Abb,Change),y=Change,fill=Region))+
  geom_bar(stat="identity",color="black")+
  scale_fill_manual(values = c("lightblue","orange"))+
  xlab("State")

#正负两极不同的着色
#思路:新建一个字段描述正负，fill=该字段
data("climate")
csub <- subset(climate,Source=="Berkeley"&Year>=1900)
csub$pos <- csub$Anomaly10y>=0
csub

ggplot(csub,aes(x=Year,y=Anomaly10y,fill=pos))+
  geom_bar(stat = "identity",position = "identity")+
  scale_fill_manual(values = c("lightblue","lightyellow"),
                    guide=FALSE)
#一年只有一个值，没有分组 guide=FALSE表示隐藏图例


#-------------------------------------------------------------------
#1.3调节条形之间的宽度和间距
#width默认是0.9代表条形的宽度  最大值是1(没有空隙)
ggplot(pg_mean,aes(x=group,y=weight))+
  geom_bar(stat="identity",width=0.5)

#调节分组条形图之间的间距
#默认的同一分组之间的条形没有间距
ggplot(cabbage_exp,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity",width=0.5,position=position_dodge(0.7))

ggplot(cabbage_exp,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity",width=0.5,position = "dodge")
#position_dodge表示两个柱子右边之间的距离，默认=width，=0就重叠


#-------------------------------------------------------------------
#1.4 堆积柱状图：position默认是stack
ggplot(cabbage_exp,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity")

#修改图例legend顺序：guides()
ggplot(cabbage_exp,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity")+
  guides(fill=guide_legend(reverse = TRUE))

#修改图像堆积顺序：要先设置因子水平factor,levels在前面的在上面
cabbage_exp$Cultivar <- factor(cabbage_exp$Cultivar,
                               levels=c("c52","c39"))

#对数据框 cabbage_exp 中名为 Cultivar 的这一列赋值
#如果这列已经存在 → 覆盖原内容,如果这列不存在 → 才会新建一列
ggplot(cabbage_exp,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity")+
  guides(fill=guide_legend(reverse = TRUE))
#factor 里“排第一的水平（第一个 level）是在下面 / 最左边”


#-------------------------------------------------------------------
#1.5柱状图进阶之加文字标签 
#标签位置的设定：vjust
ggplot(cabbage_exp,aes(x=interaction(Date,Cultivar),y=Weight))+
  geom_bar(stat="identity")+geom_text(aes(label=Weight),vjust=1.5,
                                      color="white")
#vjust=vertical justification(垂直对齐)
#用来控制文字相对于“参考点”的上下位置

#interaction 把多个分类变量“组合成一个新的因子,
#用来表示“这些分类变量的每一种组合,日期 × 品种的每一种组合

ggplot(cabbage_exp,aes(x=Date,y=Weight))+
  geom_bar(stat = "identity")
#因为数据本质是同一天(Date),不同品种(Cultivar)各有一个Weight
#如果不用interaction(),ggplot会认为这些Weight属于同一个x类别
#就没法画出并排的柱子

ggplot(cabbage_exp,aes(x=interaction(Date,Cultivar),y=Weight))+
  geom_bar(stat="identity")+geom_text(aes(label=Weight),vjust=-0.3)

#vjust<0,字在柱子上面
#设置y轴范围ylim,最大值是Weight的1.05倍
ggplot(cabbage_exp,aes(x=interaction(Date,Cultivar),y=Weight))+
  geom_bar(stat="identity")+geom_text(aes(label=Weight),
                                      vjust=-0.3)+
  ylim(0,max(cabbage_exp$Weight)*1.05)

#也可以用geom_text()调节y轴范围
#Weight是“变量名”，不是“文字”,在aes()里，变量名永远不加引号
ggplot(cabbage_exp,aes(x=interaction(Date,Cultivar),y=Weight))+
  geom_bar(stat="identity")+
  geom_text(aes(y=Weight+0.5,label = Weight))

#设置分组柱形图的标签width=position_dodge才试配,width默认是0.9
#position_dodge在geom_text里表示文本间距离
ggplot(cabbage_exp,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity",position = position_dodge(0.9))+
  geom_text(aes(label=Weight),vjust=1.5,color="white",
            position=position_dodge(0.9),size=3)

#堆积柱状图设置标签
library(plyr)
#排序规则是先看Date,小的在前大的在后
#再按 Cultivar 排序，同样从小到大
#注意
cabbage_exp$Cultivar <- factor(cabbage_exp$Cultivar,
                               levels = c("c39","c52"))
ce <- arrange(cabbage_exp,Date,Cultivar)
ce

#ddply() 的作用是：把数据框按某些变量分组，
#对每一组做同样的操作，再把结果合并成一个新的数据框
#d     d   ply
#↑     ↑   ↑
#输入 输出 操作

#基本结构：ddply(.data, .variables, .fun, ...)


#按 Date 分组，在每个日期组内，对 Weight 做累加（cumsum），
#并生成一个新列 lable_y，最后把结果保存回 ce
#transform 的含义是：在不减少行数的情况下，新增或修改列

#df2 <- transform(df,z = x + y)表示
#用 df 作为输入，新增一列 z，z = x + y，行数和 df 完全一样

#手动计算y的高度
ce <- ddply(ce,"Date",transform,label_y=cumsum(Weight))

ce$Cultivar <- factor(ce$Cultivar, levels = c("c52", "c39"))

ggplot(ce,aes(x=Date,y=Weight,fill=Cultivar))+
  geom_bar(stat="identity",position = "stack",)+
  geom_text(aes(y = label_y,label = Weight),
            vjust=1.5,color="white")


#让ggplot2自己计算y的高度
#format把数值“转成好看的字符”返回结果是character
#nsmall 是 format() 的一个参数，意思是：最少保留的小数位数
ggplot(ce, aes(x = Date, y = Weight, fill = Cultivar)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste(format(Weight,nsmall=2),"kg")),
            size=4,
            position = position_stack(vjust = 0.5),
            color = "white")


#————————————————————————————————————————————————————————————————————
#1.6饼图
data(mpg)
mpg <- mpg

#普通柱状图
ggplot(mpg,aes(class))+geom_bar()

#饼图,把y轴方向扭曲了，柱子变弯了
ggplot(mpg,aes(class))+geom_bar()+coord_polar(theta = "y")
#把y轴方向扭曲，柱子都从同一个中心出发,高度由y来确定
ggplot(mpg,aes(class))+geom_bar()+coord_polar(theta = "x")

#加上颜色分组
ggplot(mpg,aes(class))+geom_bar(aes(fill=drv))#局部映射
ggplot(mpg,aes(class,fill=drv))+geom_bar()#全局映射

#把y轴方向扭曲
ggplot(mpg,aes(class,fill=drv))+geom_bar()+
  coord_polar(theta = "y")

#把x轴方向扭曲
ggplot(mpg,aes(class,fill=drv))+geom_bar()+
  coord_polar(theta = "x")


#绘制正常的饼图
#先画堆积柱状图，且x=1，表示只有一根柱子,内部按 class 堆积
ggplot(mpg,aes(1,fill=class))+geom_bar()#默认 stat = "count"
                                        #统计每个 class 出现的次数

#在把y轴方向旋转,heta = "y" 的意思：用 y 轴的长度当作角度
#即柱子的“高度”被转换成 扇形的角度
ggplot(mpg,aes(1,fill=class))+geom_bar()+
  coord_polar(theta = "y")

#添加标签
#stat = "count"表示你这层文字，也先按 x / fill 分组，再帮我数个数
#geom_text() 默认的 stat 是："identity"表示
#不做任何统计，直接使用你数据框里“已经存在的变量”

#scales::percent(x)表示把小数 → 百分比字符串

#..count.. 是 ggplot 在“统计阶段（stat）”自动生成的临时变量，
#表示：每个分组中有多少条数据,这里是指每个class出现了多少次
#相当于table(mpg$class),如果 stat 不是 count,就不会生成..count..

ggplot(mpg,aes(1,fill=class))+geom_bar(width=0.5)+
  coord_polar(theta = "y")+
  geom_text(stat="count",
            aes(label = scales::percent(..count../sum(..count..))
                ),size=3,
            position=position_stack(vjust=0.5))


#————————————————————————————————————————————————————————————————————
#1.7克利夫兰点图
data("tophitters2001")
tophit <- tophitters2001[1:25,]
#先画散点图
ggplot(tophit,aes(x=avg,y=name))+geom_point()

#开始修改
#y=reorder(name,avg)是按照 avg 的大小,重新排列因子 name 的顺序

ggplot(tophit,aes(x=avg,y=reorder(name,avg)))+geom_point(size=3)+
  theme_bw()














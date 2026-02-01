#1,1BaseR strptime("string parse time")字符串按指定格式解析成时间
#格式和数据要匹配
#常用格式符号速查表
#符号	含义
#%Y	  四位年份（1992）#以下用/ 或- 间隔，要看文本是怎么连接的
#%y	  两位年份（92), %y 只决定如何读取年份,不决定“如何显示年份
#%m	  月
#%d	  日
                      #两者间用空格隔开
#%H	  小时（00–23）   #以下用：间隔
#%M	  分钟
#%S	  秒
d <- data.frame(
  date = c("02/27/92", "02/27/92", "01/14/92", "02/28/92"),
  time = c("23:03:20", "22:29:56", "01:03:30", "18:21:03"),
  temperature = c(-1, 0, -3, 5))
d
d <- d |> mutate(date2 = strptime(date, "%m/%d/%y"))#月 / 日 / 年
d
class(d$date)
class(d$date2)

#strptime()的format参数必须和字符串里的日期/时间“一模一样”
x <- "1992-02-27" #年 - 月 - 日
#正确写法 strptime(x, format = "%Y-%m-%d")

#-------------------------------------------------------------------
#1,2 datetime 日期 + 时间
#把 date 和 time 两个字符串，合并成一个真正的“时间点datetime对象
#1992-02-27 23:03:20

#select(-date2)：先清理数据框,把之前创建的 date2 列删掉
#
d <- d |> 
  select(-date2) |>
  mutate(datetime = strptime(
    paste(date, time), #合并两个字符串
    format = "%m/%d/%y %H:%M:%S"
  ))
d

#处理日期对象 Arbeiten mit Datums-Objekten
#日期 / 日期时间对象在 R 里，本质上是“可比较的数值型对象”
d %>% arrange(datetime) #按时间排序
d %>% pull(datetime) %>% min() #最早的时间点,pull在数据框里
                               #“拉出”一列，变成一个向量

d %>% pull(datetime) %>% max() #最晚的时间点
max(d$datetime) - min(d$datetime) #计算时间差

d$datetime > as.POSIXct("1992-02-01") #比较大小,得到逻辑向量
#POSIXct，内部是一个单一数值，含义：距离1970-01-01 00:00:00的秒数

d |> filter(datetime >= min(datetime) & 
              datetime <= max(datetime)) #筛选时间区间

#注意：
#select() 通过按【列名】选决定这张表“保留哪些列”
#filter() 通过对【元素(列)】的逻辑值判断决定这张表“保留哪些行”
#unclass()：去掉对象的class属性，直接显示它在 R 里的“底层存储形式”

difftime(max(d$datetime), min(d$datetime), 
         unit = "hours") #明确告诉R要什么单位，这里是小时

difftime(max(d$datetime), min(d$datetime), 
         unit = "weeks") # 周

#支持的常见单位 "secs"，"mins"，"hours"，"days"，"weeks"

#时间 + 数字：注意 POSIXct 单位是“秒”; Date+1 是加一天
#CET 是 Central European Time
d$datetime + 3
d$datetime + 3600 #加了1小时
as.Date("1992-02-27") + 1
as.POSIXct("1992-02-27 00:00:00") + 1


#-------------------------------------------------------------------
# 1.3 lubridate
library(lubridate)
d$date

mdy(d$date) #月日年，同理dmy()日月年，ymd_hms()年-月-日 时:分:秒
class(mdy(d$date)) #返回类型是 Date,单位是“天”,只有日期，没有时间
mdy(d$date) |> class()

mdy(d$date) + hms(d$time) # hms()：只管时间，不管日期
dtime <- mdy(d$date) + hms(d$time)
dtime
dtime |> class()# Date + hms = POSIXct;UTC = 世界时间的“基准坐标系”


# 日期对象编号 Zahlen zu Datums-Objekten
# make_date/make_datetime 不解析字符串，直接构造时间对象

make_date(year = 2008, month = 3, day = 15)

make_date(day = 15)

make_datetime(year = 2008, month = 3, day = 15, hour = 13)

make_datetime(year = 2008, month = 3, 
              day = 15, hour = 13, min = 16, sec= 37)


# Arbeiten mit Zeitdauern 处理时间段, (duration) mit d* Funktionen
#duration = 绝对时间长度用“秒”来衡量，
#不看日历、不看时区、不看月份长短
#它只做一件事：往时间轴上加---秒

#d*() 它们创建的都是 duration 对象
#ddays()  dhours() dminutes() dseconds() dyears()

d$datetime #是一个POSIXct/ POSIXt向量一个具体时间点带有时区（CET）

d$datetime + ddays(3)#

d$datetime + dhours(1)

d$datetime + 3600

d$datetime + dyears(2) + ddays(10) + dhours(3) + 
  dminutes(10) + dseconds(30) #可以随意拼装

dur <- ddays(10) + dhours(3)
dur

#对比period
#类型	       本质
#duration	   秒（物理时间）
#period	     日历单位（人类时间）

#period 在 lubridate 里长什么样
#period 内部不是一个数，而是一组日历分量
months(1) #下个月
years(2)  #两年后
days(10)  #10天后
hours(3) %>% class() #3小时候

#Extrahieren von Einzelkomponenten 提取各个成分
#首先，把字符型 "02/27/92"，转成真正的 Date 对象
#否则后面所有 year()、month() 都用不
d |> pull(date) |> mdy()

d |> pull(date) |> mdy() %>% year()#提取年份

d |> pull(date) |> mdy() |> month()#提取月份

d |> pull(date) |> mdy() |> 
  month(label = TRUE)#label = TRUE：变成人类可读的月份

d |> pull(date) |> mdy() |> 
  month(label = TRUE, abbr = FALSE)#abbr = FALSE：不用缩写

d |> pull(datetime) |> hour()#提取小时

d |> pull(datetime) |> week()#自1月1日以来经过的第几个 7 天周期

d |> pull(datetime) |> isoweek()#真正的“日历周” week


#----------------------------------------------------------------
#Feinstaubbelastung in München慕尼黑的细颗粒污染物
uwz <- readRDS("umweltzone.Rds")
uwz |> sample_n(6) #随机抽样查看数据
uwz |> pull(datum) |> class()#datum 不是字符型,而是POSIXct时间对象

#表示数据 1.从2008-01-01 00:00 开始
#2. 到2009-12-31 23:00 结束 ，覆盖整整两年
#3. 是小时级数据（23:00 是强烈信号）
range(uwz$datum)#取出时间列（POSIXct）,返回 最小值 + 最大值

#这张图“整体上”表达了：
#x 轴：2008–2009 连续时间    y 轴：PM10 浓度

#两条线：黑：Prinzregentenstraße（市中心，交通）
        #红：Johanneskirchen（相对外围）

ggplot(uwz, aes(x = datum, y = PM10_Prin)) +
  geom_line() +#第一条线:Prinzregentenstraße的PM10 随时间变化
  geom_line(aes(y = PM10_Joh), col = 2) + 
  ylab("Feinstaubbelastung")

#第二条线,局部 aesthetic覆盖，表示：在同一张图上
#用红线画 Johanneskirchen 的 PM10

# x轴仍然用：datum（继承自 ggplot）   y轴换成PM10_Joh
#col = 2，2 是 R 的基础调色板编号，通常是红色


#时间变量 → 分组分析 Feinstaubbelastung nach Jahr,按年份划分
uwz <- uwz |>
  mutate(year = year(datum)) #添加年份变量

uwz |> head() 
#注意到UZ = "nein"，说明：2008 年初环，保区尚未实施，这是政策前数据

uwz |> pull(year) |> table() #统计每年的观测数
#2009年  365 天 × 24 小时 = 8760 = 普通年份
#2008年  366 天 × 24 小时 = 8784 = 闰年

#把逐小时的 PM10 数据，按年份分组，算出每个测站的年平均浓度
uwz |>
  group_by(year) |> #分组 → 汇总
  summarize(
    mJoh = mean(PM10_Joh, na.rm = TRUE),
    mPrin= mean(PM10_Prin, na.rm = TRUE))

#Extraktion von Einzelkomponenten des Datums提取日期的各个组成部分
uwz <- uwz |>
  mutate(
    month = month(datum),
    week = week(datum),
    day = day(datum),
    hour = hour(datum),
    wday = wday(datum, week_start = 1),#一周中哪一天1-7,numeric
    wday2 = wday(datum, label = TRUE, week_start = 1),#factor
    yday = yday(datum))#一年中第几天1-365

uwz |> select(datum, year, yday, month, week, day, wday, 
              wday2, hour) |> head()

#Feinstaubbelastung pro Tag des Jahres一年中每天的粉尘污染量

#group_by(year, yday) + summarize()把“小时数据”压缩成了“每天一行”
#uwz 原始数据是：每一行 = 一个小时，一天 ≈ 24 行

#group_by(year, yday)给数据“贴分组标签”
    #这是 2008 年第 1 天 的一组（24 行）
    #那是 2009 年第 1 天 的一组（24 行）

#summarize 的规则是：每一个分组 → 输出一行
#mean(PM10_Joh)→ 把 24 个小时的值算一个平均
#sd(PM10_Joh)→ 计算这 24 个值的标准差

#如果改成 group_by(year, month)就是月平均，group_by(year)是年平均

#mutate(lJoh = mJoh - sdJoh, uJoh = mJoh + sdJoh)
#给每一天的平均 PM10 值，加上一个“上下波动范围（±1 个标准差）”

#alpha = .3控制图形的透明度（opacity）.3 表示 30% 不透明、70% 透明

#mJoh日均值，ymin = lJoh, ymax = uJoh其上下限
#geom_pointrange把它们连起来表示这一天稳不稳
#线很短 → 一整天 PM10 比较平稳
#线很长 → 有早高峰 / 晚高峰 / 突发污染

uwz |> group_by(year, yday) |>
  summarize(mJoh = mean(PM10_Joh, na.rm = TRUE), 
            sdJoh = sd(PM10_Joh, na.rm = TRUE)) |>
  mutate(lJoh = mJoh - sdJoh, uJoh = mJoh + sdJoh) |>
  ggplot(aes(x = yday, y = mJoh, col = factor(year))) +
  geom_point(alpha=0.3) + 
    geom_pointrange(aes(ymin = lJoh, ymax = uJoh))


#Feinstaubbelastung nach Wochenstunde一周内每小时的粉尘污染物情况

#什么是 Wochenstunde（周小时）
#whour = (wday - 1) × 24 + hour

#whour ∈ [0, 167]，表示一周 168小时中的哪一个
#周一：0–23 周二：24–47 周三：48–71...周日：144–167

uwz <- uwz |> mutate(whour = (wday - 1) * 24 + hour) 
uwz |> select(datum, year, week, day, wday, hour, whour) |> head()

#把“宽格式数据”变成“长格式数据”
uwz_long <- uwz |> select(year, whour, PM10_Joh, PM10_Prin) |>
  tidyr::pivot_longer(cols = c("PM10_Joh", "PM10_Prin"), 
                      names_to = "station", values_to = "PM10")

uwz_long |> sample_n(5)


#下图表示：2008 / 2009 年，在一周 168 个小时里，不同时间段的平均 
          #PM10 浓度变化（±1 个标准差），分别在两条测站对比


#在同一年、同一测站、同一“周内小时（whour）”下，
#所有出现过的 PM10 值的平均值和标准差
#共有 ：年份数 × 周小时数 × 测站数 = 2*168*2=672组

#例如 year= 200   station = PM10_Joh   whour= 87（= 周四 15:00）
#m = mean(PM10)，表示所有“周四 15:00”的 PM10 的平均值

uwz_long |> group_by(year, whour, station) |>
  summarize(m = mean(PM10, na.rm = TRUE), 
            sd = sd(PM10, na.rm = TRUE)) |>
  mutate(l = m - sd, u = m + sd) |>
  ggplot(aes(x = whour, y = m)) +
  geom_point() +
  geom_line() +
  geom_pointrange(aes(ymin = l, ymax = u)) +
  facet_grid(year ~ station) +
  geom_vline(xintercept = 24 * (1:7), lty = 2, col = "blue") +
  geom_vline(xintercept = 12 * seq(1, 13, by=2) , 
             lty = 3, col = "red")

#geom_vline() 用来在图中画“竖直参考线”
#它不表示数据本身，而是给读图的人提供参照
#xintercept 里有几个数，就画几条竖线

#最基本的用法 geom_vline(xintercept = 10) 不参与统计,只是“标记”
#在 x = 10 的位置，画一条贯穿整个图的竖线

#xintercept = 24 * (1:7) 画7条线
#c(24, 48, 72, 96, 120, 144, 168)，这是一个 长度为 7 的数值向量



#xintercept = 12 * seq(1, 13, by=2) 也是画7条线
#表示12 * c(1, 3, 5, 7, 9, 11, 13)=12  36  60  84 108 132 156
#每一天的中午 12 点，也可以用 24 * (1:7)-12


#画出一周 168 小时的周期曲线，并用竖线标出时间结构
uwz_long |> group_by(year, whour, station) |>
  summarize(m = mean(PM10, na.rm = TRUE), 
            sd = sd(PM10, na.rm = TRUE)) |>
  mutate(l = m - sd, u = m + sd) |>
  ggplot(aes(x = whour, y = m)) +
  geom_line(aes(col = factor(year))) +
  facet_grid(~station) +
  geom_vline(xintercept = 24 * (1:7), lty = 2) +
  geom_vline(xintercept = 12 * seq(1, 13, by=2) , lty = 3)

#facet_grid(行变量 ~ 列变量) (背景变量~主比较变量)
#~ 左边：行方向竖着排  ~ 右边：列方向横着排用  . 表示“这个方向不分面”


#对比08和09年早高峰7-9点时，粉尘的浓度
uwz_long |>
  mutate(
    hour = whour %% 24,
    wday = ((whour %/% 24) %% 7) + 1# %/%(整数除法) 得到这是第几天
  ) |> # %% 7 对 7 取余,把“第几天”压回 一周内的位置
  filter(
    wday <= 5, #只保留“工作日早高峰”     
    hour %in% 7:9
  ) |>
  group_by(year, station) |>
  summarize(mean_PM10 = mean(PM10, na.rm = TRUE))


























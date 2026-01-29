#1.1 Tibble Creation
#tibble::as_tibble:把已经存在的数据结构(如 data.frame)转换成tibble
#tibble::tibble:是用来 从零开始创建 tibble
#快捷键:ctrl+shift+m  %>% 
data("ChickWeight")
head(ChickWeight, 3)
chickw <- tibble::as_tibble(ChickWeight)
head(chickw, 3)


#____________________________________________________________________
#1.2 Data munging （数据清洗），即对数据做整理、变形、筛选、汇总
library(dplyr)
library(tidyr)

#Creating / modifying columns（创建 / 修改“列”）
#dplyr::mutate
#左边：weight_kg（新列名）右边：weight / 1000（算出来的对象）
mutate(chickw, weight_kg = weight / 1000)

#case_when() = 多条件if–else几乎只和mutate()一起用,用来“分类、打标签”
#dplyr::case_when
mutate(
  chickw,
  size = case_when(
    weight < 50 ~ "small",
    weight < 70 ~ "medium",
    TRUE ~ "large"#等价于else "large"
  )
)

#Selecting / removing columns（选择 / 删除“列”）
#dplyr::select
select(chickw, weight, Time) #选列
select(chickw, -Diet)        #删列

#Selecting / removing rows（选择 / 删除“行”）
#dplyr::filter  按条件选行，条件是在列里筛选的
#条件写在里面，返回满足条件的行
#注意：head()直接选前几行
filter(chickw, Time > 10, Diet == 1)

#dplyr::slice，按行号取数据
#和filter()区别：filter	看“值”，slice	看“位置”
slice(chickw, 1:5)

#Calculating summary statistics（计算汇总统计量）
#dplyr::summarize
#summarize() 的核心作用是：#多行 → 少行，常和 group_by() 一起出现
#这里是每个 Diet 一行结果
chickw %>%
  group_by(Diet) %>%
  summarize(mean_weight = mean(weight))

#dplyr::count“分组 + 计数” 的快捷写法
#等价于group_by(...) %>% summarize(n = n())
count(chickw, Diet)

#Other useful dplyr verbs（其他非常常用的动词）
#dplyr::rename ，rename() = 改列名，新的名字在前，旧的名字在后
#注意赋值是左边名字，右边对象 x <- 5
rename(chickw, chicken_id = Chick)

#dplyr::arrange ，arrange() = 排序
arrange(chickw, weight)
arrange(chickw, desc(weight))

#dplyr::pull，提取单列作为向量
pull(chickw, weight)

#dplyr::sample_n ，随机抽 n 行
sample_n(chickw, 10)

#dplyr::sample_frac ，随机抽 一定比例的行
sample_frac(chickw, 0.2)

#dplyr::group_by
#把数据“按某个变量分组”，让后面的操作“每一组各算各的”
#搭配：group_by() + summarize()
#例子：按饲料类型分组，每一组算一个平均体重
#没有 group_by()，summarize() 就是“整体算一次”
chickw %>%
  group_by(Diet) %>%
  summarize(
    mean_weight = mean(weight)
  )

chickw %>%summarize(mean_weight = mean(weight))

#group_by搭配 mutate()
#每一行加上“所在组的平均体重
chickw %>%
  group_by(Diet) %>%
  mutate(mean_weight = mean(weight))

#Transforming Data Format（数据形状转换）
#统计建模 / ggplot / 回归，更喜欢 long format

#Wide（宽表）  列>行           
#id   math  english
#1     90      85
#2     88      92

#Long（长表）  列<行 
#id   subject   score
#1    math       90
#1    english    85
#2    math       88
#2    english    92

#pivot_longer()（宽 → 长），“把多列，叠成两列”
#math、english 两列,变成一列 subject,分数进 score
df <- tibble(
  id=1:2,
  math=c(90,85),
  english=c(85,92)
)
df_long <- pivot_longer(
  df,
  cols=c(math,english),
  names_to="subject",
  values_to="score"
)
df_long
#长 → 宽
df_wider <- pivot_wider(
  df_long,
  names_from = "subject",
  values_from="score"
)

#Relational Data Operations:用“共同变量”把多张表连起来
#Inner joins: dplyr::inner_join 只保留两边都有的
students <- tibble(
  id   = c(1, 2, 3),
  name = c("Alice", "Bob", "Cathy")
)

scores <- tibble(
  id    = c(1, 2, 4),
  score = c(90, 85, 88)
)

#保留两个表的公共部分
inner_join(students, scores, by = "id")
#第一个（左表）全保留
left_join(students, scores, by = "id")
#两个数据的并集
full_join(students, scores, by = "id")


#Set operations（集合运算）注意：比的是行，不是列
#这一类函数，把 数据框当成“集合”来处理关心：
#有哪些行（row）出现了 / 没出现
#比较的是整行是否完全一样，不看行名，不产生新列

#交集:dplyr::intersect() 同时出现在 A 表 和 B 表里的行
#并集:dplyr::union()     A 或 B 里出现过的所有行（去重）
#差集:dplyr::setdiff()   只在 A 里，但不在 B 里的行

#例子
a <- tibble(
  id = c(1, 2, 3),
  score = c(90, 85, 88)
)
b <- tibble(
  id = c(2, 3, 4),
  score = c(85, 88, 90)
)
intersect(a, b)#交集，AB公有行
union(a, b)    #并集，AB所有行
setdiff(a, b)  #差集，A 独有

#调列的顺序
#手动指定            df %>% select(id, score, age)
#把某列挪到最前      df %>% select(id, everything())
#把某列挪到最后      df %>% select(-id, id)
#某列放在另一列前面  df %>% select(id, score, everything())
                    #df %>% relocate(score, .after = id)


#————————————————————————————————————————————————————————————————————
#1.3 Pipes管道符 %>% 把左边的结果，自动送进右边函数的第一个参数
f <- function(x, y) {
  y * sin(x - y)
}
f(f(1, 3), 3)         #Base R
1 %>% f(3) %>% f(3)   #Pipe（流水线）

#例子
head(chickw, 3)
dim(chickw)
dim(chickw[chickw$Time %in% 0:10 & chickw$Diet == 1, ]) #Base R
chickw %>% filter(Time %in% 0:10 & Diet == 1) %>% dim() #dplyr


#——————————————————————————————————————————————————————————————————
# 1.4 例子 Doctor Visits
library(AER)
library(dplyr)
library(ggplot2)
theme_set(theme_bw()) 
#white background（论文风）后面画的所有 ggplot 都用这个主题
data("DoctorVisits")
head(DoctorVisits, 3)

#as_tibble() 把data.frame转换成tibble
visits <- as_tibble(DoctorVisits)
head(visits)

#select()  选列（顺便）改列名
#只选一列,显示前两行
visits %>% select(visits) %>% head(2)
#同时选择多列，显示前两行
visits %>% select(visits, age, income) %>% head(2)
#按“列名规则”选择
#常见的辅助函数：
                #以a开头       starts_with("a")
                #以z结尾       ends_with("z")    
                #中间包含mid   contains("mid") 
                #所有列        everything() 
                #正则表达式    matches("regex") 
                   #^ ：以什么开头   matches("^n")，列名以 n 开头
                   #$ ：以什么结尾   matches("chronic$")
                   #普通单词：“包含” matches("chronic")
visits %>% select(ends_with("chronic")) %>% head(2)
visits %>% select(matches("chronic"))
#! um etwas nicht auszuwählen，& 表示同时满足
visits %>% select(!ends_with("chronic")) %>% head(2)
visits %>% select(!starts_with("free") & 
                    !ends_with("chronic")) %>% head(2)

#只保留这 5 列，(visits, gender, age, income, illness)，并重新赋值
visits <- visits %>%
  select(visits, gender, age, income, illness)
visits %>% head()

#pull
#pull() 用来“取出一列，并且直接变成一个向量（vector）
#注意：select() 选的是「列」，结果还是「表」
#功能上类似 $，但更适合放在 pipe %>% 里
head(visits$gender)
visits %>% pull(gender) %>% head()

#典型错误：mean() 只接受向量，select() 给你的是列表
#还想继续用 dplyr 操作用select
#要“数值/分类结果”本身用pull
#mean(visits %>% select(age)) 不行
visits %>% select(age)
mean(visits %>% pull(age))   #可以

#Häufigkeit der Besuche 就诊次数的频数分布
#table()里是向量
table(visits$visits)
visits %>% pull(visits) %>% table()

#Verteilung des Alters (age) 年龄（age）的分布
summary(visits$age)
visits %>% pull(age) %>% summary()

#summary() mean() median() sd() var() quantile()都期望输入的是向量


#mutate()用已有的列，生成“新列”或“改列”，“删除”即age=NULL
#左边永远是列名，这里叫 age
#右边的 age 指的是：原来数据中的 age 列，对这一列 逐行 × 100
#原来的 age 被覆盖（修改）了
#mutate() 返回的还是一个 tibble
#summary() 对整个表：
#数值列 → min / mean / median
#因子列 → 频数
visits %>%
  mutate(age = age * 100) %>%
  summary()

#规范数据清洗（data munging）
#变量尺度转换scaling，单位转换unit conversion，结果校验summary检查
visits <- visits %>%
  mutate(
    age = age * 100,
    income = income * 1e4 * 0.95 #1e^4=1*10^4
  )
visits %>% pull(age) %>% summary()
visits %>% pull(income) %>% summary()

#summarize() / summarise()
#summarize() = 把“很多行”压缩成“很少的行”，结果还是tibble
visits %>%
  summarize(
    mean_income = mean(income),
    q25_income  = quantile(income, 0.25),
    median_income = median(income),
    q75_income  = quantile(income, 0.75)
  )


#case_when() 用来“按条件给每一行数据分类”，相当于“向量化的 if-else-if”
#ifelse(condition, value_if_true, value_if_false)

#case_when(
#  条件1 ~ 结果1,
#  条件2 ~ 结果2,
#  ...
#  TRUE ~ 默认结果
#)

visits <- visits %>%
  mutate( #按条件新建列
    income_cat = case_when(
      income < 2325 ~ "<q25",
      income > 8370 ~ ">q75",
      TRUE ~ "q25 - q75"
    )
  )
visits %>% head(4)

#cut是按照给定的收入区间，把 income 切成几个档位（区间），
#并生成一个新的分类变量 income_cat
visits %>%
  mutate(income_cat = cut(income, c(0, 2325, 5115, 8370, 14250))) %>%
  head()

#count()
#count() = group_by() + summarize(n = n())的快捷写法,返回的是一张“频数表”
table(visits$gender)
visits %>% count(gender)

#group_by() 
#group_by()本身不算数,不改数据,只“贴分组标签”告诉后面的函数“按组”来算
visits %>% group_by(gender) %>% head(3)
#先按 gender分组，再对每个 gender 组进行计数
visits %>% group_by(gender) %>% count()
 
 #等价于：
  #n()是计数函数，表示当前这一组（group）里，有多少行数据
  #n() 只能在 summarize() 或 mutate() 里用，必须配合 group_by()
  #n = n() 的意思是：新建一列叫 n，它的值是“当前组里有多少行”
visits %>%
  group_by(gender) %>%
  summarize(n = n())

#group_by() 会“持续生效”
x <- visits %>% group_by(gender)
#之后你再写，是 按 gender 分别算平均年龄
x %>% summarize(mean(age))
#如果不想按组了，要
x %>% ungroup()
visits %>% count()
visits %>% group_by(gender) %>% ungroup() %>% count()


#Relative Häufigkeiten der Arztbesuche 就诊频率的相对变化
#group_by(gender, visits)按组合分组（交叉分组），笛卡尔乘积

#summarize,对每一个分组计算该组的行数，把结果存到一列叫freq里
#summarize() 默认会丢掉“最后一个”分组变量
#可以通过 summarize(freq = n(), .groups = "keep")来避免

#freq=这个组的人数，summarize() = 从“明细表”生成“汇总表”
v_freq <- visits %>%
  group_by(gender, visits) %>%
  summarize(freq = n()) %>% # n() 返回当前组的大小(行数)
  mutate(rel_freq = freq/sum(freq))
v_freq %>% head()

#补充
v_freq <- visits %>%
  group_by(gender, visits) %>%
  summarize(freq = n(),) %>%
  mutate(rel_freq = scales::percent(freq / sum(freq), #真正的显示百分比
                                    accuracy = 0.1))
v_freq %>% head()
v_freq
#表示84.4%男性患者在过去两周内没有就医


#用已经算好的相对频率数据，按就诊次数画柱状图，用相对频率作为高度，
#男女用不同颜色，同一就诊次数下并排对比

#x = factor(visits)，横轴是就诊次数，用 factor() 是因为：
#visits 是数值，这里我们要的是 分类柱状图，不是连续变量
#y = rel_freq，纵轴是相对频率
#gender 是分类变量

v_freq %>%
  ggplot(aes(x = factor(visits), y = rel_freq)) +
  geom_bar(stat = "identity", 
           position = "dodge",
           aes(fill = factor(gender))) 


#按收入组（income_cat）分组，统计每个收入组里有多少人
visits %>%
  group_by(income_cat) %>%
  summarize(freq = n())


#在每一个收入组income_cat内部，计算不同就诊次数visits的相对频率分布
#即同一收入水平的人，最近两周看医生 0 次 / 1 次 / 2 次 … 的比例是多少

v_freq_inc <- visits %>%
group_by(income_cat, visits) %>%
  summarize(freq = n()) %>%
  mutate(rel_freq = freq/sum(freq))
v_freq_inc %>% head()

#不同收入组（income_cat）中，就诊次数（visits）的相对频率分布，
#并把不同收入组并排比较
v_freq_inc %>%ggplot(aes(x=factor(visits),y=rel_freq))+
  geom_bar(stat = "identity",
           position = "dodge",
           aes(fill = income_cat))


#filter()用来“按条件选行（观测值）”，不会改列，只会减少行数
visits %>% dim()  #告诉基准是多少

  #不分组的 filter（全体一起算）
  #median(income)是对整个数据集，只算 一个全局中位数
  #filter()这里是保留收入低于“总体中位数”的人
visits %>%
  filter(income < median(income)) %>%
  dim() #大约一半，合理

  #重点来了：group_by(gender) + filter()
  #每个 gender 自己算一个 median，不是全体的了
visits %>%
  group_by(gender) %>%
  filter(income < median(income)) %>% 
  dim() #2217=男1244+女973！=2500，因为男女收入分布不同


#————————————————————————————————————————————————————————————————————————
# 1.5 R 语言 tidyverse 里的“特殊语法（tidy evaluation）
#分组均值（group-wise mean）

#普通的写法（不写函数）
#visits：原始数据
#group_by(gender)：按性别 gender 分组
#summarize(m = mean(income))：对每一组，计算income的平均值，命名为m
visits %>%
  group_by(gender) %>%
  summarize(m = mean(income))

#均值函数
#function(data, group_var, var)
  #data：数据框（比如 visits）
  #group_var：分组变量（比如 gender）
  #var：要算均值的变量（比如 income）

#定义函数
#group_var 和 var 传的是 列名，不是字符串
#{{ }} 是 tidyverse 的 特殊语法，相当于传一列而不是一个值
grp_mean <- function(data, group_var, var) {
  data %>%
    group_by({{ group_var }}) %>%
    summarize(m = mean({{ var }}))
}

#应用函数
#按性别（gender）分组，计算每一组的收入（income）平均值
visits %>% grp_mean(gender, income)
#按收入类别（income_cat）分组，计算访问次数（visits）这一列的平均值
visits %>% grp_mean(income_cat, visits)

#汇总变量函数
var_summary <- function(data, var) {
  data %>%
    summarise(
      n = n(),              #样本数量（行数）
      min = min({{ var }}), #该变量的最小值
      max = max({{ var }})  #该变量的最大值
    )
}

#无分组
#统计收入（income）这个变量的基本情况：样本量、最小值、最大值
visits %>% var_summary(income)
  #等价于
visits %>%
  summarise(
    n = n(),
    min = min(income),
    max = max(income)
  )
#先分组，再统计（共有3*2=6组）
#不同收入×性别下，访问次数分布：样本量、最小值、最大值
visits %>%
  group_by(income_cat, gender) %>%
  var_summary(visits)
  #等价于
visits %>%
  group_by(income_cat, gender) %>%
  summarise(
    n = n(),
    min = min(visits),
    max = max(visits)
  )


#————————————————————————————————————————————————————————————————————————
#Recidivism data 累犯数据
recidivism <- read.table(#从文本文件（txt、dat、csv等）里，把数据读进R
  file = "https://math.unm.edu/~james/Rossi.txt",
  header = TRUE #第一行是变量名，不是数据
) %>%
  as_tibble()
variable.names(recidivism) #查看数据集里有哪些变量（列名）
recidivism %>% head(6)
recidivism

#------------------------------------------------------------------------
#slice()
#按“行号”选行,不是看条件,看变量值大小
#filter(),逻辑条件（如 age > 30） ;slice(),行的位置（如第 1–5 行）

#slice() 常见写法速查表
#slice(1:5) 前5行   ,   slice(1) 第1行  ,  slice(n()) 每组最后一行
#slice(-1) 去掉第1行 ,  slice(c(1,3)) 第1和第3行

recidivism %>% slice(1:2) %>% select(1:8)

#slice() + group_by()    arrest = 0 → 取前2行  arrest = 1 → 取前2行
recidivism %>%
  group_by(arrest) %>%
  slice(1:2) %>%
  select(1:10)
#---------------------------------------------------------------------
#sample_n()
#sample_n(n) = 从数据中“随机抽取 n 行”

set.seed(123456) #固定随机数的起点，让“随机结果可以复现”
recidivism %>% sample_n(2)

#---------------------------------------------------------------------
#select()

recidivism %>%
  select(starts_with("emp")) %>%  #选出所有变量名以 "emp" 开头的列
  ncol()  #数一数现在这个数据框有多少列

#例子：第1个人的就业历史
recidivism %>%
  slice(1) %>%  # 只保留第 1 行（第 1 个受试者）
  select(starts_with("emp")) %>%  #只看就业历史
  as.numeric() 
#一个“数值向量”来表示这个人每周是否就业
#0:这一周没有工作    1:这一周有工作     NA:这一周已经不在观察期内
#为什么会有 NA？
#week = 20 arrest = 1 第 20 周就再犯，被重新抓进去了

#---------------------------------------------------------------------
#IDs hinzufügen 添加ID
#第 1 行 → ID = 1,第 2 行 → ID = 2…… ,一行 = 假设一个人
recidivism <- recidivism %>%
  mutate(ID = row_number())

recidivism <- recidivism %>%
  select(ID, everything()) #把 ID 放到第一列，其余列保持原顺序
recidivism
recidivism %>% sample_n(2)

#Transform to long format 转换成长表
#注意：生成的新数据中，列名不能重复
recidivism_long <- recidivism %>%
  rename(arrest_week = week) %>%
  pivot_longer(
    cols = starts_with("emp"),
    names_to = "week",      #原来的列名
    names_transform = list(week = readr::parse_number),
    #提取字符串里“第一个数字
    values_to = "employed", #原来的数值
    values_drop_na = TRUE   #如果不去na每个人都会被强行拉到 52 周
  ) %>% 
  select(ID, week, arrest_week, everything())
recidivism_long %>% head()
recidivism_long

#data check 数据体检
recidivism_long %>%
  filter(ID %in% c(1, 10)) %>%  #选两个具体的人ID=1,10
  group_by(ID) %>%   #按人分组1,10
  slice(1:2, (n()-1):n()) #取前 2 行 + 最后 2 行，n-1:n

#arrange() 用来按照某些变量（列）的取值，对“行”进行排序
#默认：arrange(x)升序  arrange(desc(x))降序
#arrange(x, y) 先按 x 排序，如果 x 相同，再按 y 排序

#升序 小到大
employment_summary <- recidivism_long %>%
  group_by(ID) %>%
  summarize(days_employed = sum(employed)) %>%#对每一个 ID：把所有周的 employed 加起来
  #把“多行”压缩（汇总）成“少行”               #得到总就业天数 / 周数
  arrange(days_employed)  #按就业总天数从小到大排序
employment_summary 
employment_summary %>% head(4)  #表示在观察期内一天都没有就业

#倒序 大到小
recidivism_long %>%
  group_by(ID) %>%
  summarize(days_employed = sum(employed)) %>%
  arrange(desc(days_employed)) %>%
  head(5)

#对每一个人(ID)，按周排序,然后计算“到目前为止一共工作了多少天”
recidivism_long <- recidivism_long %>%
  group_by(ID) %>%  #“按人来算”
  arrange(week) %>% #把“每个人”的数据按时间顺序排好
  mutate(cumulative_employment = cumsum(employed)) %>% #新建一列
  #每个人自己的累计就业时间
  arrange(ID) 

recidivism_long %>%
  filter(cumulative_employment != 0) %>% #隐藏从来没就业过的
  select(ID, week, employed, cumulative_employment) %>%
  head(10)


#不同的人，在出狱后，就业轨迹是否不同
#geom_line(aes(group = ID)),同一个 ID 的点才连线,不同的不连接
ggplot(recidivism_long, aes(x = week, y = cumulative_employment)) +
  geom_line(aes(group = ID)) +
  labs(
    x = "Weeks since release from prison",
    y = "Cumulative number of days employed")

#随机抽 12 个人，每个人单独画一张小图，展示各自的累计就业轨迹
id_sample <- sample(recidivism$ID, 12, replace = FALSE)#不重复抽人
recidivism_long %>%
  filter(ID %in% id_sample) %>%
  ggplot(aes(x = week, y = cumulative_employment)) + 
  geom_line() + 
  facet_wrap(~ID, labeller = "label_both", 
             nrow = 3L, 
             ncol = 4L) +
  labs(x = "Weeks since release from prison",
       y = "Cumulative number of days employed")

#注意：时间过程折线图 ：x 轴 有自然顺序（时间、年龄、阶段）
#一次性数量比较柱状图 ： x 轴是类别（人、组、地区）














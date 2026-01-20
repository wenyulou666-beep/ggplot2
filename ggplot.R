#1.疫苗接种数量
getwd()
readRDS("vaccs.Rds")
vaccs <- readRDS("vaccs.Rds")
library(ggplot2)
#1.1展示德国（DE）不同疫苗在不同日期的接种剂量随时间变化的折线图
#把折线图储存于p_vaccs
p_vaccs <- ggplot(vaccs, aes(x = date, y = dosen, col = impfstoff)) +
  geom_line()
p_vaccs

#-----------------------------------------------------------------------
#1.2用于按分组展开（使用 facet_wrap()）
#画出的是 按地区（region）分面的多组时间序列折线图

#每个小图 = 一个地区 每个小图里：是不同疫苗（颜色区分）
#随时间变化的接种剂量折线图

#非常适合横向比较地区差异
p_vaccs <- p_vaccs + facet_wrap(~region,ncol=5)
p_vaccs

#-------------------------------------------------------------------
#1.3某一个地区中某一种疫苗的接种数量随时间的变化
ggplot(vaccs,
       aes(x = date,
           y = dosen,
           col = impfstoff,
           group = interaction(region, impfstoff))) +
  geom_line()

#--------------------------------------------------------------------
#1.4更新数据但保留数据结构
vaccs_sub <- subset(
  vaccs,
  region %in% c("DE-SL","DE-HB","DE-HE","DE-BE")
)
vaccs_sub$region <- factor(vaccs_sub$region,
                              levels = c("DE-SL", "DE-HB", "DE-HE", "DE-BE"),
                              labels = c("Saarland", "Bremen", "Hessen", "Berlin"))

# %+%---保留图的所有设定，只替换数据
#等价于：“用 vaccs_sub去替换 p_vaccs 里原来的 vaccs
#但x,y轴，颜色，分组，facet_*,geom_*统统不变
p_vaccs_sub <- p_vaccs%+%vaccs_sub
p_vaccs_sub

#不用%+%，就要重写下面一堆
ggplot(vaccs_sub, aes(x = date, y = dosen, col = impfstoff)) +
  geom_line() +
  facet_wrap(~region)

#------------------------------------------------------------------
#1.5
#用来更新映射到美学属性的变量（数据 + 其他绘图设定保持不变）
#在不改数据、不重写图的前提下，新增 / 覆盖一个美学映射：
#让“疫苗类型”决定线型（linetype）
#lty = linetype 表示：实线，虚线，点画线，点线
#aes(lty = impfstoff）表示不同疫苗 → 不同线型
p_vaccs_sub + aes(lty = impfstoff)

#注意：属于“全局 aesthetic 映射层（global aesthetics）”
#      作用于所有继承该映射的几何层（geom）

#------------------------------------------------------------------
#1.6复用 ggplot 对象，用来修改标签
#p_vaccs_sub <- p_vaccs_sub +labs(...)
p_vaccs_sub <- p_vaccs_sub +
  labs(y = "Verimpfte Dosen",
       x = "Datum",
       title = "Anzahl verimpfter Dosen",
       subtitle = "Saarland, Bremen, Hessen, Berlin",
       colour = "Impstoff\nProduzent")
p_vaccs_sub
#subtitle 副标题 通常用来：说明筛选条件，标明子样本，补充背景信息

#------------------------------------------------------------------
#1.7 ggplot2 中“内容 vs 外观”分离思想的核心
#theme = 外观层（appearance layer）非数据元素
#它控制的是：字体，颜色，线条，背景，边框
#不控制：x/y是什么，分组方式，用哪些列
p_vaccs_sub +
  theme(
    axis.text.x = element_text(size = rel(1.2)),
    axis.ticks = element_line(colour = "red", linewidth = 2),
    strip.background = element_rect(fill = "steelblue"))

#axis.text.x = element_text(size = rel(1.2))用来控制x 轴刻度文字
#element_text()用来定义 文字元素的样式
#size = rel(1.2)，rel() = 相对大小，1.2 = 比默认字体 大 20%

#axis.ticks = element_line(colour = "red", linewidth = 2)
#用来控制坐标轴上的小刻度线（ticks）
#element_line() 用来控制 颜色，粗细，线型
#axis.ticks.x = x 轴的刻度线

#strip.background = element_rect(fill = "steelblue")
#效果：facet 标题背景 → 钢蓝色（steelblue)
#strip是facet 分面标题的背景条
#element_rect() 控制所有矩形元素：背景 边框 面板底色 facet strip

#填充颜色用 fill，线条/文字用 colour(color）

#整个图的背景颜色
p_vaccs_sub +
  theme(
    plot.background = element_rect(fill = "lightyellow")
  )
#一个完整“背景控制示例”
p_vaccs_sub +
  theme(
    plot.background  = element_rect(fill = "lightyellow"),
    panel.background = element_rect(fill = "grey95"),
    strip.background = element_rect(fill = "steelblue"),
    legend.background = element_rect(fill = "lightgreen")
  )


#-------------------------------------------------------------------
#1.8
p_vaccs_sub +
  theme(
    legend.position = "bottom",
    legend.text = element_text(face = "italic"),
    legend.background = element_rect(fill = "steelblue"),
  )

#legend.position = "bottom"设置图例的位置 
#"right"# 默认  "left" "top" "bottom" "none"    

#legend.text = element_text(face = "italic")
#legend.text指的是 图例中每一项的文字如： 疫苗名称 地区名称 
#颜色对应的分类名
#face = "italic" → 斜体 
#face = "plain" 普通，face = "bold"粗体
#图例由三类东西组成：图例背景	legend.background
                    #图例文字	legend.text
                    #图例 key（小方块/小线段）	legend.key
#如果你想改 key 的背景：
#theme(legend.key = element_rect(fill = "white"))


#ggplot2 的 theme 是按“图的不同组成区域”来分组的
#这些区域包括：axis（坐标轴）legend（图例）panel（数据面板）
#plot（整张图）strip（分面标题）

#axis 控制“坐标轴怎么看起来”
#常见 axis 元素 axis.title.x  axis.title.y  axis.text.x
#axis.text.y  axis.ticks  axis.ticks.x  axis.line

#panel 是数据真正被画出来的地方
#也就是：折线 点 柱子 网格线 所在的区域
#panel ≠ plot  panel 只是 plot 里面的一部分
#常见 panel 元素panel.background  panel.grid.major
#panel.grid.minor  panel.border

#plot 是最外层，包住一切
#常见 plot 元素 plot.title  plot.subtitle  plot.background
#plot.title.position

#strip —— 分面标题
#strip 只在用了 facet_wrap / facet_grid 时才出现
#常见 strip 元素  strip.text  strip.background
#theme 只控制“怎么显示”，不控制“显示什么”

#------------------------------------------------------------------
#1.9把 plot / panel / grid 三个层级一次性连起来了
p_vaccs_sub +
  theme(
    plot.background = element_rect(fill = "firebrick4"),
    panel.background = element_rect(fill = "yellow"),
    panel.grid.minor = element_line(color = "black", 
                                    linetype = 2, linewidth = 2),
    panel.grid.major = element_line(color = "blue")
  )

#plot.background = element_rect(fill = "firebrick4")
#plot.background：整张图的最外层背景
#包括：标题 副标题 图例 panel strip
#element_rect()是因为这是一个矩形区域
#效果：整个图外框背景变成深红色

#panel.background = element_rect(fill = "yellow")
#panel.background：真正画数据的那一块区域
#折线、点、柱子都画在这里  panel 在 plot 里面 
#效果：黄色只出现在坐标轴围起来的那一块

#panel.grid.minor = element_line(
                    #color = "black", linetype = 2, linewidth = 2)
#次网格线（minor grid）介于主刻度之间的辅助线
#参数解释：color线颜色  linetype=2虚线dashed  linewidth=2线宽
#效果：次网格线变成又黑又粗的虚线
#主网格线 panel.grid.major = element_line(color = "blue")


#theme_bw()帮我把整张图的外观，一次性设成 白底 + 学术风格
p_vaccs_sub + theme_bw()
#bw = black & white

#-------------------------------------------------------------------
#1.10 Axis limits und Sub-Graphen坐标轴范围与子图
#我只想看 x 在 1 到 2 之间的部分,于是就要限制坐标轴范围axis limits
#第一种方法：xlim()（危险点）  xlim(c(1, 2))
#把 x < 1 或 x > 2 的数据直接删掉,ggplot 只剩下 x ∈ [1, 2] 的数据
#所有统计计算 都只基于这些剩余数据
#回归直线,平滑曲线,均值等
#后果:回归线斜率改变,统计结果被“人为截断”,容易产生错误结论

#第二种方法：coord_cartesian()  coord_cartesian(xlim = c(1, 2))
#先用全部数据算图,最后只显示 x 在 [1, 2] 的那一段

#-------------------------------------------------------------------
#1.11 patchwork
#patchwork用来组合不同ggplot图---facet用来拆分同一种ggplot图
#patchwork操作的对象是图,而不是数据

library(patchwork)
install.packages("palmerpenguins")
library(palmerpenguins)
penguins <- penguins

p_scatter <- ggplot(penguins, aes(x = bill_depth_mm, 
                                  y = bill_length_mm)) +
  geom_point(aes(col = species))
p_scatter

p_box <- penguins[!is.na(penguins$sex), ] |>
  ggplot(aes(x = species, y = body_mass_g, fill = sex)) +
  geom_boxplot()
p_box
#penguins[!is.na(penguins$sex), ]
#去掉 sex 是 NA 的行，因为箱线图按 sex 分组，不能有 NA

p_bar <- ggplot(penguins, aes(x = island, fill = species)) + 
  geom_bar()
p_bar

(p_scatter | p_bar) / p_box 
#基于patchwork |是横向排列  /是上下堆叠
#p_scatter | p_bar 是左边是散点图，右边是柱状图
#(p_scatter | p_bar) / p_box 是第二行即下面放一个 p_box










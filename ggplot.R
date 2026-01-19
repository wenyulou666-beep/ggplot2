#1.疫苗接种数量
getwd()
readRDS("vaccs.Rds")
vaccs <- readRDS("vaccs.Rds")
library(ggplot2)
#1.1展示德国（DE）不同疫苗在不同日期的接种剂量随时间变化的折线图
p_vaccs <- ggplot(vaccs, aes(x = date, y = dosen, col = impfstoff)) +
  geom_line()
p_vaccs

#1.2用于按分组展开（使用 facet_wrap()）
#画出的是 按地区（region）分面的多组时间序列折线图

#每个小图 = 一个地区 每个小图里：是不同疫苗（颜色区分）
#随时间变化的接种剂量折线图

#非常适合横向比较地区差异
p_vaccs <- p_vaccs + facet_wrap(~region,ncol=5)
p_vaccs

#1.3某一个地区中某一种疫苗的接种数量随时间的变化
ggplot(vaccs,
       aes(x = date,
           y = dosen,
           col = impfstoff,
           group = interaction(region, impfstoff))) +
  geom_line()














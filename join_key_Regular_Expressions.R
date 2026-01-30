# Joins是一种基于共同关键列（key），
#将两个数据集（如 tibble 或 data.frame）合并的方法

# keys在两张表中都存在、并且用来匹配数据的列
#学生表（students）
#student_id	name
#1	张三
#2	李四

#成绩表（scores）
#student_id	score
#1	90
#2	85

#这里的 student_id 就是 key（关键列）通过 Join，我们可以得到：
#student_id	name	score
#1	          张三	 90
#2	          李四	 85 

#--------------------------------------------------------------
#1.2 Join-Typen Join 的类型
library(knitr)

#1 Mutating Joins（变形连接）
#会改变表的结构,把 y 表的列“加”到 x 表中
#结果通常是：列变多了
id <- c(1,2,3)
id <- c(2,3,4)
name <- c('A','B','C')
score <- c(85,90,88)

df1 <- data.frame(id,name)
df2 <- data.frame(id,score)
x <- as_tibble(df1)
y<- as_tibble(df2)

inner_join(x,y, by = "id") %>% #只保留 x 和 y 都有的 id
  kable() #是用来把数据表“漂亮地显示出来”的函数

left_join(x, y, by = "id") #保留 x 中所有行，
                           #y中能匹配的就加上，不能的用 NA

right_join(x, y, by = "id")#保留 y 中所有行

full_join(x, y, by = "id")# 保留 x 和 y 的所有行


c#2 Filtering Joins（筛选连接）
#不会增加列，只筛选行,只根据 y 表的存在与否
#决定 x 表中哪些行要保留
semi_join(x, y, by = "id") %>% #只保留x中那些id在y里出现过的行
  kable()
#理解这些学生有没有成绩？

anti_join(x, y, by = "id") %>% #只保留x中那些id没在y里出现的行
  kable()
#理解:哪些学生没考试？

#也可以和管道操作符一起用
x %>% left_join(y,by="id") %>% kable()


#___________________________________________________________________
#2.1 Zeichenketten（字符串）
# \ 是 转义符, 表示“不要把后面的引号当作字符串结束
print("\"String\" within a string")
#cat() 把字符串按“最终文本效果”直接输出
cat("Single quotes \" must be escaped")

#特殊 Zeichenketten 以反斜杠 \ 开头的字符
#\n 换行（neue Zeile）
print("Zeilen\numbruch")
cat("Zeilen\numbruch")
writeLines("Zeilen\numbruch")

#\t 制表符（tab）表示一个缩进,相当于按一次 Tab 键
cat("\tText")

#例子
print("\t\u00E4\n\t\u00F6")
cat("\t\u00E4\n\t\u00F6")
writeLines("This is a backslash: \\")#想要“显示一个真正的反斜杠”

#字符个数 nchar()
nchar(c("Siri", "Alexa"))#"Siri"有4个字符"Alexa"有5个字符

#拆分字符串 strsplit()
strsplit("my_name", split = "_") #返回的是 list（列表）

#拼接字符串paste() / paste0()
paste("my", "name", sep = "_") #paste()：默认中间有空格
                               #paste0()：中间什么都不加

#模板 + 变量sprintf()
#%s 是 占位符（placeholder）后面的参数会按顺序填进去
my_favorite <- function(...) {
  sprintf("My favorite %s is %s.", ...)
}
my_favorite("movie", "'Demolition man'")

#替换字符串 sub() vs gsub()
#sub()：只替换第一个
sub("1", "i", "S1r1")
#替换所有 gsub()
gsub("1", "i", "S1r1") #g = global（全局）

# 函数命名统一用 stringr Paket
library(stringr)
#字符串长度 str_length()
str_length(c("Siri", "Alexa"))

#拼接字符串 str_c()
str_c("Siri", "Alexa")
str_c("Siri", "Alexa", sep = ", ")
str_c(c("Siri", "Alexa"), collapse = ", ")
str_c(c("Siri", "Alexa"), c("us", "nder"), collapse = ", ")
# sep：横着连  collapse：竖着收
#sep：定义同一位置的元素如何连接（逐元素拼接）
#collapse：定义整个字符向量如何合并为一个字符串
str_c(
  c("Siri", "Alexa"),
  c("us", "nder"),
  sep = "-",
  collapse = ", "
)

#按位置截取str_sub()
str_sub("°Siri°", 2, 3) #第 1 个字符是 °

#大小写转换
#upper：全大写 ,title：每个单词首字母大写
str_to_upper(c("warning", "stop"))
str_to_title("this is a movie title")
str_to_lower("Hello World")

#排序str_sort()
str_sort(c("Siri", "Alexa")) #按字母顺序排序,默认区分大>小写
str_sort(c("apple", "Banana", "cherry", "Apple")
         ,locale = "C")

#替换与删除
str_replace("S1r1", "1", "i") #只替换第一个
#替换全部
str_remove_all("°Siri°", "i") #删除匹配部分

#weitere Beispiele:
KI <- c("Siri", "Alexa", "HAL 9000")

#“有没有？”（TRUE / FALSE）str_detect()
#区分大小写,返回的是 逻辑向量
str_detect(KI, pattern = "a")
#不包含 "a" 的是哪些
str_detect(KI, pattern = "a", negate = TRUE) #取反

#“在哪里？”（位置）str_locate()
#只找 第一个,返回的是一个 矩阵（start / end）
str_locate(KI, pattern = "a")

#“留下谁？”（筛选内容）str_subset()
str_subset(KI, "a") #返回包含模式的那些元素本身
#等价于：
KI[str_detect(KI, "a")]
str_subset(KI, "A") #大小写的对比

#“是第几个？”（索引）str_which()
str_which(KI, "A") #哪些位置的元素包含 "A"？

#“出现了几次？”str_count()
str_count(KI, "A") #每个元素中，模式出现了多少次


#------------------------------------------------------------
#Regular Expressions 正则表达式
#正则表达式不是“具体的字符串”，
#而是“描述一类字符串的规则（pattern）”

#正则函数
#或者（OR）x|y ,满足一个即可
str_detect(KI, "A|B")

#以 A 开头 ^A
str_detect(x, "^A")
str_detect(KI, "A.") # A 后面跟着任意 1 个字符

#至少一次 +
str_detect(x, "a+") #至少 1 个 a（可以更多）

#零次或多次 *
str_detect(KI, "a*")#这个几乎所有字符串都会 TRUE
                    #“0 个 a” 也是合法的匹配

#字符集合（任选一个）[xy] ,和 "A|B" 很像，但写法更短
str_detect(x, "[AB]")

#取反（不是这些）[^xy]
#几乎所有字符串都会匹配，因为：只要有一个别的字符就行
str_detect(x, "[^AB]") #包含“不是 A 或 B”的字符
                       #只要有一个“不是 A/B 的字符”，立刻 TRUE

#字母 + 数字 [:alnum:]
str_detect(x, "[[:alnum:]]")

#字母[:alpha:] 或 [A-Za-z]
str_detect(x, "[[:alpha:]]")

#数字[:digit:] 或 [0-9]
str_detect(x, "[[:digit:]]") #包含数字即可,如A1,B_2,abc123


#正则表达式 + stringr 各函数“各司其职”
#例子
KI <- c("Siri", "Alexa", "HAL 9000")

#数一数匹配了多少次
str_count(KI, "[[:alpha:]]") #每个字符串里有多少个字母

#只留下“符合条件”的字符串
str_subset(KI, "[[:digit:]]") #只保留“包含数字”的元素

# 改字符串内容
str_remove(KI, "[[:digit:]]") #"HAL 9000" 中只删第一个数字9

#删第一段连续数字 
str_remove(KI, "[[:digit:]]+") #9000 整段被删掉

#全删
str_remove_all(KI, "[[0-9]]") #所有数字全部删掉

#只取第一个匹配
str_extract(KI, "[[:digit:]]") #"HAL 9000" → 第一个数字是"9"

#提取连续数字
str_extract(KI, "[[:digit:]]+") #提取的是“整段数字” 9000

#删除所有元音字母
str_remove_all(KI, "[aeiou]") #默认 区分大小写

#特定字符替换（Unicode）
str_replace_all(
  "Länderspezifische Sonderzeichen sind äußerst problematisch!",
  "\u00E4",
  "ae"
)#\u00E4 = ä,把 ä → ae,常用于 德语 → ASCII 转换

#正则里的“转义（escape）
#. 在正则里 = 任意字符
str_remove_all("Ein Satz, ohne Punkt. und Komma!", 
               ",|\\.|\\!") #\\. 表示真正的点号

str_remove_all("Ein Satz, ohne Punkt. und Komma!",
               "[,.!]") #[]里：点号不再是“任意字符”

str_remove_all("Ein Satz, ohne Punkt. und Komma!",
               "[[:punct:]]") #删除所有标点符号

str_remove_all(
  "Ein Satz, ohne Punkt. und Komma!",
  "[[:punct:][:space:]]") #终极清理（标点 + 空格）


#注意：
#[  [:digit:]  ]
#↑        ↑
#选一个  数字类

#最核心的两层结构：第一层R，第二层regex正则引擎
#只给 R 看 → 一个 \  给正则看 → 两个 \







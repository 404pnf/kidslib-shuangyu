
# Goal

Generate html for individual book.  Book contents are in db/*.csv

我们先生成每本书单独的csv文件。

# Usage

## 一期
01...rb和02..rb

都可以不带任何参数运行。参数都写死在脚本了。

## 二期

mergeexcel.py使用方法

    python3 mergeexcel.py inputfoder -f*xls

输出的文件在脚本执行的目录。输出的文件是tsv。

然后运行03..05的rb脚本。不需要带参数。

# Note

A customized bookify plugin for turning page is used.

<https://github.com/404pnf/bookify>
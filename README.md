## VIMIM 中文输入法插件

[原插件地址](https://www.vim.org/scripts/script.php?script_id=2506)

## 安装

将`plugin`目录下面的 2 个文件，拖到`vim`的`plugin`目录里即可，或者是使用`vundle`和`plug`来管理`vim`插件。

## 配置

在`.vimrc`配置文件中加入以下配置，避免输入法状态下搜索功能按键显示有问题：

```vim
set imsearch=0
```

## 输入法切换

简化了部分功能，加入极点五笔输入法作为默认输入法，如需要调整输入法，可以从[这里](https://code.google.com/archive/p/vimim/downloads?page=2)下载其他输入法码表，或者从[ime](https://github.com/yuweijun/vimim/tree/master/ime)文件夹里找一个码表替换极点五笔输入法。

## 使用

在普通或者插入模式中按快捷键`Ctrl-Space`就可以输入中文了。

## 与英文混排输入的问题

一般在输入英文单词前后用空格与中文字符分隔开来，如果需要中英文混排并且不要插入空格的话，则在输入英文单词之后按回车符，则英文词上屏后就可以接着输入中文了。

## plugin/vimim.wubijd.txt

里面五笔词汇调整了一些个人使用词语的先后顺序，如`线程`调整到`纯种`前面。


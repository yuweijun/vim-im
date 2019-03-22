## vimim 中文输入法插件

[原版插件地址](https://www.vim.org/scripts/script.php?script_id=2506)

## 安装

### 下载输入法简化版本

原来的这个插件功能很强大，并支持云输入法，我将里面部分不太常用到的功能精简了一下，并把 python 相关的脚本也都移除了，安装方式如下：

```bash
git clone https://github.com/yuweijun/vim-im.git
```

### 复制插件

将`vim-im/plugin`目录下面的 2 个文件，复制到 vim 的`plugin`目录里即可，或者是使用`vundle`和`vim-plug`来管理 vim 插件。

## 配置

在`.vimrc`配置文件中加入以下配置，避免输入法状态下搜索功能按键显示有问题：

```vim
set imsearch=0
```

## 输入法切换

简化了部分功能，加入极点五笔输入法作为默认输入法，如需要调整输入法，可以从[这里](https://code.google.com/archive/p/vimim/downloads?page=2)下载其他输入法码表，或者从 [ime](https://github.com/yuweijun/vim-im/tree/master/ime) 文件夹里找一个码表替换极点五笔输入法。

## 使用

在普通或者插入模式中按快捷键`Ctrl-_`，也就是`Ctrl` + `Shift` + `-`，就可以输入中文了，个人会增加`Ctrl-Space`这个组合键用来切换输入法，在`.vimrc`中加入以下配置：

```vim
imap <C-Space> <C-_>
nmap <C-Space> <C-_>
```

<!-- more -->

## 与英文混排输入的问题

一般在输入英文单词前后用空格与中文字符分隔开来，如果需要中英文混排并且不要插入空格的话，则在输入英文单词之后按回车符，则英文词上屏后就可以接着输入中文了。

### vim-space 插件

关于这个中英文之间的空格处理，我写了个专门处理空格的 [vim 插件](https://github.com/yuweijun/vim-space.git)，安装完之后，执行`<leader>sa`组合键就可以在中英文之间自动添加一个空格，这里的`<leader>`符在 vim 中默认是`\`，但我个人习惯都是将之映射改为逗号`,`。

## plugin/vimim.wubijd.txt

里面五笔词汇调整了一些个人使用词语的先后顺序，如`线程`调整到`纯种`前面。


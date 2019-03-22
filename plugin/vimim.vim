" ===========================================================
"                VimIM —— Vim 中文輸入法简化版
" ===========================================================
let s:url = ' http://vimim.googlecode.com/svn/vimim/vimim.vim.html'
let s:url = ' http://code.google.com/p/vimim/source/list'
let s:url = ' http://vim.sf.net/scripts/script.php?script_id=2506'

let s:VimIM  = [" ====  introduction     ==== {{{"]
" =================================================
"    File: vimim.vim
"  Author: vimim <vimim@googlegroups.com>
" License: GNU Lesser General Public License
"  Readme: VimIM is a Vim plugin as an Input Method for i_CTRL-^ in Vim
"    (1) do Chinese input without mode change: Midas touch
"  PnP: Plug and Play
"    (1) drop the vimim.vim to the plugin folder: plugin/vimim.vim
"    (2) [option] drop supported datafiles, like: plugin/vimim.wubijd.txt
"  Usage: VimIM takes advantage of the definition from Vim
"    (1) :help i_CTRL-^  Toggle the use of language      ...
"    (2) :help i_CTRL-_  Switch between languages        ...

" ============================================= }}}
let s:VimIM += [" ====  initialization   ==== {{{"]
" =================================================

function! s:vimim_bare_bones_vimrc()
    set cpoptions=Bce$ go=cirMehf shm=aoOstTAI noloadplugins
    set gcr=a:blinkon0 shellslash noswapfile hlsearch viminfo=
    set fencs=ucs-bom,utf8,chinese,gb18030 gfn=Courier_New:h12:w7
    set enc=utf8 gfw=YaHei_Consolas_Hybrid,NSimSun-18030
endfunction

if exists("g:Vimim_profile") || &iminsert == 1 || v:version < 700
    finish
elseif &compatible
    call s:vimim_bare_bones_vimrc()
endif

scriptencoding utf-8
let g:Vimim_profile = reltime()
let s:plugin = expand("<sfile>:p:h")

function! s:vimim_initialize_global()
    highlight  default lCursorIM guifg=NONE guibg=green gui=NONE
    highlight! link lCursor lCursorIM
    let s:space = '　'
    let s:colon = '：'
    let g:Vimim = "VimIM　中文輸入法"
    let s:multibyte    = &encoding =~ "utf-8" ? 3 : 2
    let s:localization = &encoding =~ "utf-8" ? 0 : 2
    let s:seamless_positions = []
    let s:starts = { 'row' : 0, 'column' : 1 }
    let s:quanpin_table = {}
    let s:shuangpin_table = {}
    let s:shuangpin = 'abc ms plusplus purple flypy nature'
    let s:abcd = split("'abcdvfgxz", '\zs')
    let s:qwer = split("pqwertyuio", '\zs')
    let s:az_list = map(range(97,122),"nr2char(".'v:val'.")")
    let s:valid_keys = s:az_list
    let s:valid_keyboard = "[0-9a-z']"
    let s:valid_wubi_keyboard = "[0-9a-z]"
    let s:shengmu_list = split('b p m f d t l n g k h j q x r z c s y w')
    let s:pumheights = { 'current' : &pumheight, 'saved' : &pumheight }
    let s:backend = { 'datafile' : {}, 'directory' : {} }
    let s:ui = { 'root' : '', 'im' : '', 'quote' : 0, 'frontends' : [] }
    let s:rc = {}
    let s:rc["g:Vimim_mode"] = 'dynamic'
    let s:rc["g:Vimim_shuangpin"] = 0
    let s:rc["g:Vimim_toggle"] = 0
    let s:rc["g:Vimim_plugin"] = s:plugin
    let s:rc["g:Vimim_punctuation"] = 2
    call s:vimim_set_global_default()
    let s:plugin = isdirectory(g:Vimim_plugin) ? g:Vimim_plugin : s:plugin
    let s:plugin = s:plugin[-1:] != "/" ? s:plugin."/" : s:plugin
    let s:dynamic    = {'dynamic':1,'static':0}
    let s:static     = {'dynamic':0,'static':1}
endfunction

function! s:vimim_dictionary_keycodes()
    let s:keycodes = {}
    for key in split( ' pinyin ')
        let s:keycodes[key] = "['a-z0-9]"
    endfor
    for key in split('array30 phonetic')
        let s:keycodes[key] = "[.,a-z0-9;/]"
    endfor
    for key in split('zhengma taijima wubi cangjie hangul xinhua quick')
        let s:keycodes[key] = "['a-z]"
    endfor
    let s:keycodes.wu       = "['a-z]"
    let s:keycodes.nature   = "['a-z]"
    let s:keycodes.yong     = "['a-z.;/]"
    let s:keycodes.erbi     = "['a-z.;/,]"
    let s:keycodes.boshiamy = "['a-z.],[]"
    let ime  = ' pinyin_sogou pinyin_quote_sogou pinyin_huge'
    let ime .= ' pinyin_fcitx pinyin_canton pinyin_hongkong'
    let ime .= ' wubi98 wubi2000 wubijd wubihf'
    let s:all_vimim_input_methods = keys(s:keycodes) + split(ime)
endfunction

function! s:vimim_set_frontend()
    let quote = 'erbi wu nature yong boshiamy'
    let s:valid_keyboard = "[0-9a-z']"
    if !empty(s:ui.root) && empty(g:Vimim_shuangpin)
        let s:valid_keyboard = s:backend[s:ui.root][s:ui.im].keycode
    elseif g:Vimim_shuangpin == 'ms' || g:Vimim_shuangpin == 'purple'
        let s:valid_keyboard = "[0-9a-z';]"
    endif
    let i = 0
    let keycode_string = ""
    while i < 16*16
        if nr2char(i) =~# s:valid_keyboard
            let keycode_string .= nr2char(i)
        endif
        let i += 1
    endwhile

    let s:valid_keys = split(keycode_string, '\zs')
    let s:wubi = s:ui.im =~ 'wubi\|erbi' ? 1 : 0
    let s:ui.quote = match(split(quote),s:ui.im) < 0 ? 0 : 1
    let s:gi_dynamic = 0
    let logo = s:chinese('chinese',s:mode.static?'static':'dynamic')
    let tail = s:chinese('halfwidth')
    if g:Vimim_punctuation > 0 && s:toggle_punctuation > 0
        let tail = s:chinese('fullwidth')
    endif
    let g:Vimim = "VimIM".s:space.logo.' '.s:vimim_im_chinese().' '.tail
endfunction

function! s:vimim_set_global_default()
    let s:vimimrc = []
    let s:vimimdefaults = []
    for variable in keys(s:rc)
        if exists(variable)
            let value = string(eval(variable))
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimrc, '    ' . vimimrc)
        else
            let value = string(s:rc[variable])
            let vimimrc = ':let ' . variable .' = '. value .' '
            call add(s:vimimdefaults, '  " ' . vimimrc)
        endif
        exe 'let '. variable .'='. value
    endfor
endfunction

function! s:vimim_cache()
    let results = []
    if !empty(s:pageup_pagedown)
        let length = len(s:match_list)
        if length > &pumheight
            let page = s:pageup_pagedown * &pumheight
            let partition = page ? page : length+page
            let B = s:match_list[partition :]
            let A = s:match_list[: partition-1]
            let results = B + A
        endif
    endif
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  user interface   ==== {{{"]
" =================================================

function! s:vimim_dictionary_punctuations()
    let s:antonym = " 〖〗 （） 《》 【】 ‘’ “”"
    let one =       " { }  ( )  < >  [  ] "
    let two = join(split(join(split(s:antonym)[:3],''),'\zs'))
    let antonyms = s:vimim_key_value_hash(one, two)
    let one = " ,  .  +  -  ~  ^    _    "
    let two = " ， 。 ＋ － ～ …… —— "
    let mini_punctuations = s:vimim_key_value_hash(one, two)
    let one = " @  :  #  &  %  $  !  =  ;  ?  * "
    let two = " 　 ： ＃ ＆ ％ ￥ ！ ＝ ； ？ ﹡"
    let most_punctuations = s:vimim_key_value_hash(one, two)
    call extend(most_punctuations, antonyms)
    let s:key_evils = { '\' : "、", "'" : "‘’", '"' : "“”" }
    let s:all_evils = {}
    call extend(s:all_evils, mini_punctuations)
    call extend(s:all_evils, most_punctuations)
    let s:punctuations = {}
    if g:Vimim_punctuation > 0
        call extend(s:punctuations, mini_punctuations)
    endif
    if g:Vimim_punctuation > 1
        call extend(s:punctuations, most_punctuations)
    endif
endfunction

function! g:Vimim_bracket(offset)
    let cursor = ""
    let range = col(".") - 1 - s:starts.column
    let repeat_times = range / s:multibyte + a:offset
    if repeat_times
        let cursor = repeat("\<Left>\<Delete>", repeat_times)
    elseif repeat_times < 1
        let cursor = strpart(getline("."), s:starts.column, s:multibyte)
    endif
    return cursor
endfunction

function! s:vimim_get_label(label)
    let labeling = a:label == 10 ? "0" : a:label
    return labeling
endfunction

function! s:vimim_set_pumheight()
    let &completeopt = 'menuone'
    let &pumheight = s:pumheights.saved
    if empty(&pumheight)
        let &pumheight = 5
        if len(s:valid_keys) > 28
            let &pumheight = 10
        endif
    endif
    let &pumheight = &pumheight
    let s:pumheights.current = copy(&pumheight)
endfunction

function! s:vimim_im_chinese()
    if empty(s:ui.im)
        return "==broken interface to vim=="
    endif
    let backend = s:backend[s:ui.root][s:ui.im]
    let title = has_key(s:keycodes, s:ui.im) ? backend.chinese : ''
    if s:ui.im =~ 'wubi'
        for wubi in split('wubi98 wubi2000 wubijd wubihf')
            if get(split(backend.name, '/'),-1) =~ wubi
                let title .= s:chinese(wubi)
            endif
        endfor
    endif
    if !empty(g:Vimim_shuangpin)
        let title = s:chinese(s:space, g:Vimim_shuangpin, 'shuangpin')
    endif
    if g:Vimim_shuangpin =~ 'abc'
        let title = substitute(title,s:chinese('pin'),s:chinese('hit'),'')
    endif
    return title
endfunction

function! g:Vimim_esc()
    let key = nr2char(27)  "  <Esc> is <Esc>
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  lmap imap nmap   ==== {{{"]
" =================================================

function! g:Vimim_cycle_vimim()
    if s:mode.static || s:mode.dynamic
        let s:toggle_punctuation = (s:toggle_punctuation + 1) % 2
    endif
    sil!call s:vimim_set_frontend()
    sil!call s:vimim_set_keyboard_maps()
    return ""
endfunction

function! g:Vimim_label(key)
    let key = a:key
    if pumvisible()
        let n = match(s:abcd, key)
        if key =~ '\d'
            let n = key < 1 ? 9 : key - 1
        endif
        let yes = repeat("\<Down>", n). '\<C-Y>'
        let omni = '\<C-R>=g:Vimim()\<CR>'
        if len(yes)
            sil!call s:vimim_reset_after_insert()
        endif
        let key = yes . omni
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_page(key)
    let key = a:key
    if pumvisible()
        let page = '\<C-E>\<C-R>=g:Vimim()\<CR>'
        if key =~ '[][]'
            let left  = key == "]" ? "\<Left>"  : ""
            let right = key == "]" ? "\<Right>" : ""
            let _ = key == "]" ? 0 : -1
            let backspace = '\<C-R>=g:Vimim_bracket('._.')\<CR>'
            let key = '\<C-Y>' . left . backspace . right
        elseif key =~ '[=.]'
            let s:pageup_pagedown = &pumheight ? 1 : 0
            let key = &pumheight ? page : '\<PageDown>'
        elseif key =~ '[-,]'
            let s:pageup_pagedown = &pumheight ? -1 : 0
            let key = &pumheight ? page : '\<PageUp>'
        endif
    elseif key =~ "[][=-]"
        let key = g:Punctuation(key)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Wubi()
    if s:gi_dynamic_on
        let s:gi_dynamic_on = 0 | return ""
    endif
    let key = pumvisible() ? '\<C-E>' : ""
    if s:wubi && empty(len(get(split(s:keyboard),0))%4)
        let key = pumvisible() ? '\<C-Y>' : key
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_punctuation_maps()
    for _ in keys(s:all_evils)
        if _ !~ s:valid_keyboard
            exe 'lnoremap<buffer><expr> '._.' g:Punctuation("'._.'")'
        endif
    endfor
endfunction

function! g:Punctuation(key)
    let key = a:key
    if s:toggle_punctuation > 0
        if pumvisible() || getline(".")[col(".")-2] !~ '\w'
            if has_key(s:punctuations, a:key)
                let key = s:punctuations[a:key]
            endif
        endif
    endif
    if pumvisible()
        let key = a:key == ";" ? '\<C-N>\<C-Y>' : '\<C-Y>' . key
    elseif s:gi_dynamic
        let key = a:key == ";" ? '\<C-N>' : key
        call g:Vimim_space()
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_pagedown()
    let key = ' '
    if pumvisible()
        let s:pageup_pagedown = &pumheight ? 1 : 0
        let key = &pumheight ? g:Vimim() : '\<PageDown>'
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_space()
    " (1) Space after English (valid keys)    => trigger keycode menu
    " (2) Space after omni popup menu         => insert Chinese
    " (3) Space after pattern not found       => Space
    let key = " "
    if pumvisible()
        let key = '\<C-R>=g:Vimim()\<CR>'
        let cursor = s:mode.static ? '\<C-P>\<C-N>' : ''
        let key = cursor . '\<C-Y>' . key
    elseif s:pattern_not_found
    elseif s:mode.dynamic
    elseif s:mode.static
        let key = s:vimim_left() ? g:Vimim() : key
    elseif s:seamless_positions == getpos(".")
        let s:smart_enter = 0
    elseif s:gi_dynamic
        let key = ''
        let s:gi_dynamic_on = 1
    endif
    call s:vimim_reset_after_insert()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Vimim_enter()
    let s:omni = 0
    let key = ""
    if pumvisible()
        let key = "\<C-E>"
        let s:smart_enter = 1
    elseif s:vimim_left()
        let s:smart_enter = 1
        if s:seamless_positions == getpos(".")
            let s:smart_enter += 1
        endif
    else
        let s:smart_enter = 0
    endif
    if s:smart_enter == 1
        let s:seamless_positions = getpos(".")
    else
        let key = "\<CR>"
        let s:smart_enter = 0
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  mode: chinese    ==== {{{"]
" =================================================

function! g:Vimim_chinese()
    let s:mode = g:Vimim_mode =~ 'static' ? s:static : s:dynamic
    let s:switch = empty(s:ui.frontends) ? -1 : s:switch ? 0 : 1
    return s:switch<0 ? "" : s:switch ? s:vimim_start() : s:vimim_stop()
endfunction

function! s:vimim_set_keyboard_maps()
    let common_punctuations = split("] [ = -")
    let common_labels = s:ui.im =~ 'phonetic' ? [] : range(10)
    let s:gi_dynamic = 0
    let both_dynamic = s:mode.dynamic || s:gi_dynamic ? 1 : 0
    if both_dynamic
        for char in s:valid_keys
            sil!exe 'lnoremap<silent><buffer> ' . char . ' ' .
            \ '<C-R>=g:Wubi()<CR>' . char . '<C-R>=g:Vimim()<CR>'
        endfor
    elseif s:mode.static
        for char in s:valid_keys
            sil!exe 'lnoremap<silent><buffer> ' . char . ' ' .  char
        endfor
    else
        let common_punctuations += split(". ,")
        let common_labels += s:abcd[1:]
        let pqwertyuio = []
    endif
    if g:Vimim_punctuation < 0
    elseif both_dynamic || s:mode.static
        sil!call s:vimim_punctuation_maps()
    endif
    for _ in common_punctuations
        if _ !~ s:valid_keyboard
            sil!exe 'lnoremap<buffer><expr> '._.' g:Vimim_page("'._.'")'
        endif
    endfor
    for _ in common_labels
        sil!exe 'lnoremap<buffer><expr> '._.' g:Vimim_label("'._.'")'
    endfor
endfunction

function! s:vimim_set_im_toggle_list()
    let toggle_list = []
    if g:Vimim_toggle < 0
        let toggle_list = [get(s:ui.frontends,0)]
    elseif empty(g:Vimim_toggle)
        let toggle_list = s:ui.frontends
    else
        for toggle in split(g:Vimim_toggle, ",")
            for [root, im] in s:ui.frontends
                if toggle == im
                    call add(toggle_list, [root, im])
                endif
            endfor
        endfor
    endif
    let s:frontends = copy(toggle_list)
    let s:ui.frontends = copy(toggle_list)
    let s:ui.root = get(get(s:ui.frontends,0), 0)
    let s:ui.im   = get(get(s:ui.frontends,0), 1)
endfunction

function! s:vimim_get_seamless(cursor_positions)
    if empty(s:seamless_positions)
    \|| s:seamless_positions[0] != a:cursor_positions[0]
    \|| s:seamless_positions[1] != a:cursor_positions[1]
    \|| s:seamless_positions[3] != a:cursor_positions[3]
        return -1
    endif
    let current_line = getline(a:cursor_positions[1])
    let seamless_column = s:seamless_positions[2]-1
    let len = a:cursor_positions[2]-1 - seamless_column
    let snip = strpart(current_line, seamless_column, len)
    if empty(len(snip))
        return -1
    endif
    for char in split(snip, '\zs')
        if char !~ s:valid_keyboard
            return -1
        endif
    endfor
    return seamless_column
endfunction

let s:translators = {}
function! s:translators.translate(english) dict
    let inputs = split(a:english)
    return join(map(inputs,'get(self.dict,tolower(v:val),v:val)'), '')
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: unicode   ==== {{{"]
" =================================================

function! s:vimim_i18n(line)
    let line = a:line
    if s:localization == 1
        return iconv(line, "chinese", "utf-8")
    elseif s:localization == 2
        return iconv(line, "utf-8", &enc)
    endif
    return line
endfunction

function! s:vimim_left()
    let key = 0
    let one_byte_before = getline(".")[col(".")-2]
    if one_byte_before =~ '\s' || empty(one_byte_before)
        let key = ""
    elseif one_byte_before =~# s:valid_keyboard
        let key = 1
    endif
    return key
endfunction

function! s:vimim_key_value_hash(single, double)
    let hash = {}
    let singles = split(a:single)
    let doubles = split(a:double)
    for i in range(len(singles))
        let hash[get(singles,i)] = get(doubles,i)
    endfor
    return hash
endfunction

function! s:chinese(...)
    let chinese = ""
    for english in a:000
        let cjk = english
        let chinese .= cjk
    endfor
    return chinese
endfunction

function! s:vimim_filereadable(filename)
    let datafile_1 = s:plugin . a:filename
    if filereadable(datafile_1)
        return datafile_1
    endif
    return ""
endfunction

function! s:vimim_readfile(datafile)
    let lines = []
    if filereadable(a:datafile)
        if s:localization
            for line in readfile(a:datafile)
                call add(lines, s:vimim_i18n(line))
            endfor
        else
            return readfile(a:datafile)
        endif
    endif
    return lines
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: pinyin    ==== {{{"]
" =================================================

function! s:vimim_get_all_valid_pinyin_list()
return split(" 'a 'ai 'an 'ang 'ao ba bai ban bang bao bei ben beng bi
\ bian biao bie bin bing bo bu ca cai can cang cao ce cen ceng cha chai
\ chan chang chao che chen cheng chi chong chou chu chua chuai chuan
\ chuang chui chun chuo ci cong cou cu cuan cui cun cuo da dai dan dang
\ dao de dei deng di dia dian diao die ding diu dong dou du duan dui dun
\ duo 'e 'ei 'en 'er fa fan fang fe fei fen feng fiao fo fou fu ga gai
\ gan gang gao ge gei gen geng gong gou gu gua guai guan guang gui gun
\ guo ha hai han hang hao he hei hen heng hong hou hu hua huai huan huang
\ hui hun huo 'i ji jia jian jiang jiao jie jin jing jiong jiu ju juan
\ jue jun ka kai kan kang kao ke ken keng kong kou ku kua kuai kuan kuang
\ kui kun kuo la lai lan lang lao le lei leng li lia lian liang liao lie
\ lin ling liu long lou lu luan lue lun luo lv ma mai man mang mao me mei
\ men meng mi mian miao mie min ming miu mo mou mu na nai nan nang nao ne
\ nei nen neng 'ng ni nian niang niao nie nin ning niu nong nou nu nuan
\ nue nuo nv 'o 'ou pa pai pan pang pao pei pen peng pi pian piao pie pin
\ ping po pou pu qi qia qian qiang qiao qie qin qing qiong qiu qu quan
\ que qun ran rang rao re ren reng ri rong rou ru ruan rui run ruo sa sai
\ san sang sao se sen seng sha shai shan shang shao she shei shen sheng
\ shi shou shu shua shuai shuan shuang shui shun shuo si song sou su suan
\ sui sun suo ta tai tan tang tao te teng ti tian tiao tie ting tong tou
\ tu tuan tui tun tuo 'u 'v wa wai wan wang wei wen weng wo wu xi xia
\ xian xiang xiao xie xin xing xiong xiu xu xuan xue xun ya yan yang yao
\ ye yi yin ying yo yong you yu yuan yue yun za zai zan zang zao ze zei
\ zen zeng zha zhai zhan zhang zhao zhe zhen zheng zhi zhong zhou zhu
\ zhua zhuai zhuan zhuang zhui zhun zhuo zi zong zou zu zuan zui zun zuo")
endfunction

function! s:vimim_quanpin_transform(pinyin)
    if empty(s:quanpin_table)
        for key in s:vimim_get_all_valid_pinyin_list()
            if key[0] == "'"
                let s:quanpin_table[key[1:]] = key[1:]
            else
                let s:quanpin_table[key] = key
            endif
        endfor
        for shengmu in s:shengmu_list + split("zh ch sh")
            let s:quanpin_table[shengmu] = shengmu
        endfor
    endif
    let item = a:pinyin
    let index = 0
    let pinyinstr = ""
    while index < len(item)
        if item[index] !~ "[a-z]"
            let index += 1
            continue
        endif
        for i in range(6,1,-1)
            let tmp = item[index : ]
            if len(tmp) < i
                continue
            endif
            let end = index+i
            let matchstr = item[index : end-1]
            if has_key(s:quanpin_table, matchstr)
                let tempstr  = item[end-1 : end]
                let tempstr2 = item[end-2 : end+1]
                let tempstr3 = item[end-1 : end+1]
                let tempstr4 = item[end-1 : end+2]
                if (tempstr == "ge" && tempstr3 != "ger")
                \ || (tempstr == "ne" && tempstr3 != "ner")
                \ || (tempstr4 == "gong" || tempstr3 == "gou")
                \ || (tempstr4 == "nong" || tempstr3 == "nou")
                \ || (tempstr  == "ga"   || tempstr == "na")
                \ ||  tempstr2 == "ier"  || tempstr == "ni"
                \ ||  tempstr == "gu"    || tempstr == "nu"
                    if has_key(s:quanpin_table, matchstr[:-2])
                        let i -= 1
                        let matchstr = matchstr[:-2]
                    endif
                endif
                let pinyinstr .= "'" . s:quanpin_table[matchstr]
                let index += i
                break
            elseif i == 1
                let pinyinstr .= "'" . item[index]
                let index += 1
                break
            else
                continue
            endif
        endfor
    endwhile
    return pinyinstr[0] == "'" ? pinyinstr[1:] : pinyinstr
endfunction

function! s:vimim_more_pinyin_datafile(keyboard, sentence)
    let results = []
    let backend = s:backend[s:ui.root][s:ui.im]
    for candidate in s:vimim_more_pinyin_candidates(a:keyboard)
        let pattern = '^' . candidate . '\>'
        let cursor = match(backend.lines, pattern, 0)
        if cursor < 0
            continue
        elseif a:sentence
            return [candidate]
        endif
        let oneline = get(backend.lines, cursor)
        call extend(results, s:vimim_make_pairs(oneline))
    endfor
    return results
endfunction

function! s:vimim_get_pinyin(keyboard)
    let keyboard = s:vimim_quanpin_transform(a:keyboard)
    let results = split(keyboard, "'")
    if len(results) > 1
        return results
    endif
    return []
endfunction

function! s:vimim_more_pinyin_candidates(keyboard)
    " make standard menu layout:  mamahuhu => mamahu, mama
    if s:ui.im !~ 'pinyin' || !empty(g:Vimim_shuangpin)
        return []
    endif
    let candidates = []
    let keyboards = s:vimim_get_pinyin(a:keyboard)
    if len(keyboards)
        for i in reverse(range(len(keyboards)-1))
            let candidate = join(keyboards[0 : i], "")
            if !empty(candidate)
                call add(candidates, candidate)
            endif
        endfor
        if len(candidates) > 2
            let candidates = candidates[0 : len(candidates)-2]
        endif
    endif
    return candidates
endfunction

" ============================================= }}}
let s:VimIM += [" ====  input: shuangpin ==== {{{"]
" =================================================

function! s:vimim_shuangpin_generic()
    let shengmu_list = {}
    for shengmu in s:shengmu_list
        let shengmu_list[shengmu] = shengmu
    endfor
    let shengmu_list["'"] = "o"
    let yunmu_list = {}
    for yunmu in split("a o e i u v")
        let yunmu_list[yunmu] = yunmu
    endfor
    return [shengmu_list, yunmu_list]
endfunction

function! s:vimim_shuangpin_rules(shuangpin, rules)
    let rules = a:rules
    let key  = ' ou ei ang en iong ua er ng ia ie ing un uo in ue '
    let key .= ' uan iu uai ong eng iang ui ai an ao iao ian uang '
    let v = ''
    if a:shuangpin == 'ms'
        let v = join(split('bzhfswrgwx;pontrqysgdvljkcmdy','\zs'))
        call extend(rules[0], { "zh" : "v", "ch" : "i", "sh" : "u" })
        let key .= 'v'
    elseif a:shuangpin == 'abc'
        let v = 'b q h f s d r g d x y n o c m p r c s g t m l j k z w t'
        call extend(rules[0], { "zh" : "a", "ch" : "e", "sh" : "v" })
    elseif a:shuangpin == 'nature'
        let v = 'b z h f s w r g w x y p o n t r q y s g d v l j k c m d'
        call extend(rules[0], { "zh" : "v", "ch" : "i", "sh" : "u" })
    elseif a:shuangpin == 'plusplus'
        let v = 'p w g r y b q t b m q z o l x c n x y t h v s f d k j h'
        call extend(rules[0], { "zh" : "v", "ch" : "u", "sh" : "i" })
    elseif a:shuangpin == 'purple'
        let v = 'z k s w h x j t x d ; m o y n l j y h t g n p r q b f g'
        call extend(rules[0], { "zh" : "u", "ch" : "a", "sh" : "i" })
    elseif a:shuangpin == 'flypy'
        let v = 'z w h f s x r g x p k y o b t r q k s g l v d j c n m l'
        call extend(rules[0], { "zh" : "v", "ch" : "i", "sh" : "u" })
    endif
    call extend(rules[1], s:vimim_key_value_hash(key, v))
    return rules
endfunction

function! s:vimim_create_shuangpin_table(rules)
    let pinyin_list = s:vimim_get_all_valid_pinyin_list()
    let sptable = {}
    for key in pinyin_list
        if key !~ "['a-z]*"
            continue
        endif
        let shengmu = key[0]
        let yunmu = key[1:]
        if key[1] == "h"
            let shengmu = key[:1]
            let yunmu = key[2:]
        endif
        if has_key(a:rules[0], shengmu)
            let shuangpin_shengmu = a:rules[0][shengmu]
        else
            continue
        endif
        if has_key(a:rules[1], yunmu)
            let shuangpin_yunmu = a:rules[1][yunmu]
        else
            continue
        endif
        let sp1 = shuangpin_shengmu.shuangpin_yunmu
        if !has_key(sptable, sp1)
            let sptable[sp1] = key[0] == "'" ? key[1:] : key
        endif
    endfor
    if match(split("abc purple nature flypy"), g:Vimim_shuangpin) > -1
        let jxqy = {"jv":"ju", "qv":"qu", "xv":"xu", "yv":"yu"}
        call extend(sptable, jxqy)
    elseif g:Vimim_shuangpin == 'ms'
        let jxqy = {"jv":"jue", "qv":"que", "xv":"xue", "yv":"yue"}
        call extend(sptable, jxqy)
    endif
    if g:Vimim_shuangpin == 'flypy'
        let key   = 'ou eg  er an ao ai aa en oo os  ah  ee ei'
        let value = 'ou eng er an ao ai a  en o  ong ang e  ei'
        call extend(sptable, s:vimim_key_value_hash(key, value))
    endif
    if g:Vimim_shuangpin == 'nature'
        let nature = {"aa":"a", "oo":"o", "ee":"e" }
        call extend(sptable, nature)
    endif
    for [key, value] in items(a:rules[0])
        let sptable[value] = key
        if key[0] == "'"
            let sptable[value] = ""
        endif
    endfor
    return sptable
endfunction

function! s:vimim_shuangpin_transform(keyboard)
    let size = strlen(a:keyboard)
    let ptr = 0
    let output = ""
    let bchar = ""
    while ptr < size
        if a:keyboard[ptr] !~ "[a-z;]"
            let output .= a:keyboard[ptr]
            let ptr += 1
        else
            let sp1 = a:keyboard[ptr]
            if a:keyboard[ptr+1] =~ "[a-z;]"
                let sp1 .= a:keyboard[ptr+1]
            endif
            if has_key(s:shuangpin_table, sp1)
                let output .= bchar . s:shuangpin_table[sp1]
            else
                let output .= sp1
            endif
            let ptr += strlen(sp1)
        endif
    endwhile
    return output[0] == "'" ? output[1:] : output
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: file    ==== {{{"]
" =================================================

function! s:vimim_set_datafile(im, datafile)
    let im = a:im
    if isdirectory(a:datafile) | return
    elseif im =~ '^wubi'       | let im = 'wubi'
    elseif im =~ '^pinyin'     | let im = 'pinyin' | endif
    let s:ui.root = 'datafile'
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.datafile[im] = {}
    let s:backend.datafile[im].root = s:ui.root
    let s:backend.datafile[im].im = s:ui.im
    let s:backend.datafile[im].name = a:datafile
    let s:backend.datafile[im].keycode = s:keycodes[im]
    let s:backend.datafile[im].chinese = s:chinese(im)
    let s:backend.datafile[im].lines = []
endfunction

function! s:vimim_sentence_datafile(keyboard)
    let backend = s:backend[s:ui.root][s:ui.im]
    let fuzzy = s:ui.im =~ 'pinyin' ? ' ' : ""
    let pattern = '^\V' . a:keyboard . fuzzy
    let cursor = match(backend.lines, pattern)
    if cursor > -1 | return a:keyboard | endif
    let candidates = s:vimim_more_pinyin_datafile(a:keyboard,1)
    if !empty(candidates) | return get(candidates,0) | endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1
        let pattern = '^\V' . strpart(a:keyboard,0,max) . ' '
        let cursor = match(backend.lines, pattern)
        if cursor > -1 | break | endif
    endwhile
    return cursor < 0 ? "" : a:keyboard[: max-1]
endfunction

function! s:vimim_get_from_datafile(keyboard)
    let fuzzy = s:ui.im =~ 'pinyin' ? ' ' : ""
    let pattern = '^\V' . a:keyboard . fuzzy
    let backend = s:backend[s:ui.root][s:ui.im]
    let cursor = match(backend.lines, pattern)
    if cursor < 0 | return [] | endif
    let oneline = get(backend.lines, cursor)
    let results = split(oneline)[1:]
    if len(results) > 10
        return results
    endif
    if s:ui.im =~ 'pinyin'
        let extras = s:vimim_more_pinyin_datafile(a:keyboard,0)
        let results = s:vimim_make_pairs(oneline) + extras
    else
        let results = []
        let s:show_extra_menu = 1
        for i in range(10)
            let cursor += i
            let oneline = get(backend.lines, cursor)
            let results += s:vimim_make_pairs(oneline)
        endfor
    endif
    return results
endfunction

function! s:vimim_make_pairs(oneline)
    if empty(a:oneline) || match(a:oneline,' ') < 0
        return []
    endif
    let oneline_list = split(a:oneline)
    let menu = remove(oneline_list, 0)
    let results = []
    for chinese in oneline_list
        call add(results, menu .' '. chinese)
    endfor
    return results
endfunction

" ============================================= }}}
let s:VimIM += [" ====  backend: dir     ==== {{{"]
" =================================================

function! s:vimim_set_directory(dir)
    let im = "pinyin"
    let s:ui.root = 'directory'
    let s:ui.im = im
    call insert(s:ui.frontends, [s:ui.root, s:ui.im])
    let s:backend.directory[im] = {}
    let s:backend.directory[im].root = s:ui.root
    let s:backend.directory[im].im = im
    let s:backend.directory[im].name = a:dir
    let s:backend.directory[im].keycode = s:keycodes[im]
    let s:backend.directory[im].chinese = s:chinese(im)
endfunction

function! s:vimim_sentence_directory(keyboard, directory)
    let filename = a:directory . a:keyboard
    if filereadable(filename) | return a:keyboard | endif
    let max = len(a:keyboard)
    while max > 1
        let max -= 1 " workaround: filereadable("/filename.") return true
        let head = strpart(a:keyboard, 0, max)
        let filename = a:directory . head
        if filereadable(filename) && head[-1:-1] != "." | break | endif
    endwhile
    return filereadable(filename) ? a:keyboard[: max-1] : ""
endfunction

function! s:vimim_set_backend_embedded()
    let dir = s:plugin . "pinyin"
    if isdirectory(dir)
        if filereadable(dir . "/pinyin")
            return s:vimim_set_directory(dir . "/")
        endif
    endif
    for im in s:all_vimim_input_methods
        let datafile = s:vimim_filereadable("vimim." . im . ".txt")
        if empty(datafile)
            let filename = "vimim." . im . "." . &encoding . ".txt"
            let datafile = s:vimim_filereadable(filename)
        endif
        if !empty(datafile)
            call s:vimim_set_datafile(im, datafile)
        endif
    endfor
endfunction

function! s:vimim_sort_on_length(i1, i2)
    return len(a:i2) - len(a:i1)
endfunc

" ============================================= }}}
let s:VimIM += [" ====  core workflow    ==== {{{"]
" =================================================

function! s:vimim_start()
    sil!call s:vimim_save_vimrc()
    sil!call s:vimim_set_vimrc()
    sil!call s:vimim_set_frontend()
    sil!call s:vimim_set_keyboard_maps()
    lnoremap <silent><buffer> <expr> <Esc>   g:Vimim_esc()
    lnoremap <silent><buffer> <expr> <C-L>   g:Vimim_cycle_vimim()
    if s:ui.im =~ 'array'
        lnoremap <silent><buffer> <expr> <CR>    g:Vimim_space()
        lnoremap <silent><buffer> <expr> <Space> g:Vimim_pagedown()
    else
        lnoremap <silent><buffer> <expr> <CR>    g:Vimim_enter()
        lnoremap <silent><buffer> <expr> <Space> g:Vimim_space()
    endif
    let key = ''
    if empty(s:ctrl6)
        let s:ctrl6 = 32911
        let key = nr2char(30)
    endif
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_stop()
    if has("gui_running")
        lmapclear
    endif
    " i_CTRL-^
    let key = nr2char(30)
    let s:ui.frontends = copy(s:frontends)
    sil!call s:vimim_restore_vimrc()
    sil!call s:vimim_super_reset()
    sil!exe 'sil!return "' . key . '"'
endfunction

function! s:vimim_save_vimrc()
    let s:omnifunc    = &omnifunc
    let s:complete    = &complete
    let s:completeopt = &completeopt
endfunction

function! s:vimim_set_vimrc()
    set title noshowmatch shellslash
    set completeopt=menuone
    set complete=.
    set nolazyredraw
    set omnifunc=VimIM
endfunction

function! s:vimim_restore_vimrc()
    let &omnifunc    = s:omnifunc
    let &complete    = s:complete
    let &completeopt = s:completeopt
    let &pumheight   = s:pumheights.saved
endfunction

function! s:vimim_super_reset()
    sil!call s:vimim_reset_before_anything()
    sil!call s:vimim_reset_before_omni()
    sil!call s:vimim_reset_after_insert()
endfunction

function! s:vimim_reset_before_anything()
    let s:has_shuangpin_transform = 0
    let s:mode = s:static
    let s:keyboard = ""
    let s:omni = 0
    let s:ctrl6 = 0
    let s:switch = 0
    let s:toggle_im = 0
    let s:smart_enter = 0
    let s:gi_dynamic_on = 0
    let s:toggle_punctuation = 1
    let s:popup_list = []
endfunction

function! s:vimim_reset_before_omni()
    let s:show_extra_menu = 0
endfunction

function! s:vimim_reset_after_insert()
    let s:match_list = []
    let s:pageup_pagedown = 0
    let s:pattern_not_found = 0
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core engine      ==== {{{"]
" =================================================

function! VimIM(start, keyboard)
let valid_keyboard = s:wubi ? s:valid_wubi_keyboard : s:valid_keyboard
if a:start
    let cursor_positions = getpos(".")
    let start_row = cursor_positions[1]
    let start_column = cursor_positions[2]-1
    let current_line = getline(start_row)
    let before = current_line[start_column-1]
    let seamless_column = s:vimim_get_seamless(cursor_positions)
    if seamless_column < 0
        let s:seamless_positions = []
        let last_seen_bslash_column = copy(start_column)
        let last_seen_nonsense_column = copy(start_column)
        let all_digit = 1
        while start_column
            if before =~# valid_keyboard
                let start_column -= 1
                if before !~# "[0-9']" || s:ui.im =~ 'phonetic'
                    let last_seen_nonsense_column = start_column
                    let all_digit = all_digit ? 0 : all_digit
                endif
            elseif before == '\'
                let s:pattern_not_found = 1
                return last_seen_bslash_column
            else
                break
            endif
            let before = current_line[start_column-1]
        endwhile
        if all_digit < 1 && current_line[start_column] =~ '\d'
            let start_column = last_seen_nonsense_column
        endif
    else
        let start_column = seamless_column
    endif
    let len = cursor_positions[2]-1 - start_column
    let keyboard = strpart(current_line, start_column, len)
    if s:keyboard !~ '\S\s\S'
        let s:keyboard = keyboard
    endif
    let s:starts.column = start_column
    return start_column
else
    if s:omni < 0
        return [s:space]
    endif
    let results = s:vimim_cache()
    if empty(results)
        sil!call s:vimim_reset_before_omni()
    else
        return s:vimim_popupmenu_list(results)
    endif
    let keyboard = a:keyboard
    if !empty(str2nr(keyboard))
        let keyboard = get(split(s:keyboard),0)
    endif
    if empty(keyboard) || keyboard !~ valid_keyboard
        return []
    endif
    if !empty(g:Vimim_shuangpin)
        if empty(s:shuangpin_table)
            let rules = s:vimim_shuangpin_generic()
            let rules = s:vimim_shuangpin_rules(g:Vimim_shuangpin, rules)
            let s:shuangpin_table = s:vimim_create_shuangpin_table(rules)
        endif
        if empty(s:has_shuangpin_transform)
            let keyboard = s:vimim_shuangpin_transform(keyboard)
            let s:keyboard = keyboard
        endif
    endif
    if empty(results)
        if s:wubi && len(keyboard) > 4
            let keyboard = strpart(keyboard, 4*((len(keyboard)-1)/4))
            let s:keyboard = keyboard
        endif
        let results = s:vimim_embedded_backend_engine(keyboard)
    endif
    if empty(results)
        let s:pattern_not_found = 1
    endif
    return s:vimim_popupmenu_list(results)
endif
endfunction

function! s:vimim_popupmenu_list(lines)
    let s:match_list = a:lines
    let keyboards = split(s:keyboard)  " mmmm => ['m',"m'm'm"]
    let keyboard = join(keyboards,"")
    let tail = len(keyboards) < 2 ? "" : get(keyboards,1)
    if empty(a:lines) || type(a:lines) != type([])
        return []
    endif
    let label = 1
    let one_list = []
    let s:popup_list = []
    for chinese in s:match_list
        let complete_items = {}
        let titleline = s:vimim_get_label(label)
        let menu = ""
        let pairs = split(chinese)
        let pair_left = get(pairs,0)
        if len(pairs) > 1 && pair_left !~ '[^\x00-\xff]'
            let chinese = get(pairs,1)
            let menu = s:show_extra_menu ? pair_left : menu
        endif
        let label2 = ' '
        let titleline = printf('%3s ', label2 . titleline)
        let chinese .= empty(tail) || tail == "'" ? '' : tail
        let complete_items["abbr"] = titleline . chinese
        let complete_items["menu"] = menu
        let label += 1
        let complete_items["dup"] = 1
        let complete_items["word"] = empty(chinese) ? s:space : chinese
        call add(s:popup_list, complete_items)
    endfor
    call s:vimim_set_pumheight()
    return s:popup_list
endfunction

function! s:vimim_embedded_backend_engine(keyboard)
    let keyboard = a:keyboard
    if empty(s:ui.im) || empty(s:ui.root)
        return []
    endif
    let head = 0
    let results = []
    let backend = s:backend[s:ui.root][s:ui.im]
    if backend.name =~ "quote" && keyboard !~ "[']"
        let keyboard = s:vimim_quanpin_transform(keyboard)
    endif
    if s:ui.root =~# "directory"
        let head = s:vimim_sentence_directory(keyboard, backend.name)
        let results = s:vimim_readfile(backend.name . head)
        if keyboard ==# head && len(results) && len(results) < 20
            let extras = []
            for candidate in s:vimim_more_pinyin_candidates(keyboard)
                let lines = s:vimim_readfile(backend.name . candidate)
                let extras += map(lines, 'candidate." ".v:val')
            endfor
            let results = extras + map(results, 'keyboard." ".v:val')
        endif
    elseif s:ui.root =~# "datafile"
        if empty(backend.lines)
            let backend.lines = s:vimim_readfile(backend.name)
        endif
        let head = s:vimim_sentence_datafile(keyboard)
        let results = s:vimim_get_from_datafile(head)
    endif
    if s:keyboard !~ '\S\s\S'
        if empty(head)
            let s:keyboard = keyboard
        elseif len(head) < len(keyboard)
            let tail = strpart(keyboard,len(head))
            let s:keyboard = head . " " . tail
        endif
    endif
    return results
endfunction

function! g:Vimim()
    let s:omni = s:omni < 0 ? -1 : 0
    let s:keyboard = empty(s:pageup_pagedown) ? "" : s:keyboard
    let key = s:vimim_left() ? '\<C-X>\<C-O>\<C-R>=g:Omni()\<CR>' : ""
    sil!exe 'sil!return "' . key . '"'
endfunction

function! g:Omni()
    let s:omni = s:omni < 0 ? 0 : 1
    let key = s:mode.static ? '\<C-N>\<C-P>' : '\<C-P>\<Down>'
    let key = pumvisible() ? key : ""
    sil!exe 'sil!return "' . key . '"'
endfunction

" ============================================= }}}
let s:VimIM += [" ====  core driver      ==== {{{"]
" =================================================

function! s:vimim_plug_and_play()
    nnoremap <silent> <C-_> a<C-R>=g:Vimim_chinese()<CR>
    inoremap <unique> <C-_>  <C-R>=g:Vimim_chinese()<CR>
endfunction

sil!call s:vimim_initialize_global()
sil!call s:vimim_dictionary_punctuations()
sil!call s:vimim_dictionary_keycodes()
sil!call s:vimim_super_reset()
sil!call s:vimim_set_backend_embedded()
sil!call s:vimim_set_im_toggle_list()
sil!call s:vimim_plug_and_play()
:let g:Vimim_profile = reltime(g:Vimim_profile)
" ============================================= }}}

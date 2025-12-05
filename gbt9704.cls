%% gbt9704.cls
%% 基于 GB/T 9704-2012 的党政机关公文格式 LaTeX 模板
%% 
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{gbt9704}[2025/12/04 Standard Document of Party and Government Organs]

\LoadClass[UTF8,a4paper,linespread=1.5,twoside]{ctexart}

% ==================================================
% 1. 页面设置 (Page Layout)
% ==================================================
\RequirePackage{geometry}
\geometry{
    paper=a4paper,
    top=37mm,
    bottom=35mm,
    left=28mm,
    right=26mm,
    footskip=25mm
}

% ==================================================
% 2. 字体定义 (Fonts) A 根据用户要求定制
% 依赖 fontspec。推荐使用 XeLaTeX 编译。
% ==================================================
\RequirePackage{fontspec}

% 1. 西文数字和字符使用 Times New Roman
\setmainfont{Times New Roman}
\setCJKmainfont[AutoFakeBold=true]{FangSong}

% 2. 明确映射中文族字体到用户指定的物理字体名
\setCJKfamilyfont{fangsong}{FangSong} % 仿宋
\setCJKfamilyfont{kaishu}{KaiTi}     % 楷体
\setCJKfamilyfont{songti}{SimSun}   % 宋体 > 小标宋/正文标题备用
\setCJKfamilyfont{xiaobiao}{方正小标宋简体}
\setCJKfamilyfont{heiti}{SimHei}

% 定义“小标宋”字体宏，使用 SimSun 加粗模拟
\newcommand\xiaobiao{\CJKfamily{xiaobiao}}

% ==================================================
% 3. 版面元素与样式
% ==================================================
\RequirePackage{fancyhdr}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
\RequirePackage{titlesec}
\RequirePackage{zhnumber}
\RequirePackage{pifont}
\RequirePackage{array}
\RequirePackage{etoolbox}
\RequirePackage{multirow}
\RequirePackage{eqparbox}
\RequirePackage{xparse}

\definecolor{gbred}{RGB}{255,0,0}

% AAA 导言 AAA
\AtBeginDocument{
    \zihao{3}
    \titlespacing*{\section}{2em}{0pt}{0pt}
    \titlespacing*{\subsection}{2em}{0pt}{0pt}
    \titlespacing*{\subsubsection}{2em}{0pt}{0pt}
    \titlespacing*{\paragraph}{2em}{0pt}{0pt}
    \titlespacing*{\subparagraph}{2em}{0pt}{0pt}
}

% AAA 页码 AAA
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\fancyhf{}
\fancyfoot[RO,LE]{\zihao{4}—\ \thepage\ —}

% AAA 标题样式 AAA
% 这里的 \heiti, \kaishu, \fangsong 均调用了上面定义的字体
\setcounter{secnumdepth}{4} % 设置章节编号的深度
\ctexset{
    section = {
      number = \chinese{section}、,
      format = \zihao{3}\heiti,
      aftername = \hspace{0pt},
     },
    subsection = {
            number = （\chinese{subsection}）,
            format = \zihao{3}\kaishu,
            aftername = \hspace{0pt},
        },
    subsubsection = {
            number = \arabic{subsubsection}．,
            format = \zihao{3}\fangsong,
            aftername = \hspace{0pt},
        },
    paragraph = {
            number = （\arabic{paragraph}）,
            format = \zihao{3}\fangsong,
            aftername = \hspace{0pt},
        },
    subparagraph = {
            format = \zihao{3}\fangsong,
        }
}

% ==================================================
% 4. 变量定义
% ==================================================
\newcommand{\@gbDocNo}{}
\newcommand{\@gbUrgLv}{}
\newcommand{\@gbDocNum}{}
\newcommand{\@gbSigner}{}
\newcommand{\@gbIsuOrg}{}
\newcommand{\@gbcla}{}
\newcommand{\@gbclb}{}
\newcommand{\emptyA}{}


\newcommand{\gbDocNo}[1]{\renewcommand{\@gbDocNo}{#1}}
\newcommand{\gbUrgLv}[1]{\renewcommand{\@gbUrgLv}{#1}}
\newcommand{\gbDocNum}[1]{\renewcommand{\@gbDocNum}{#1}}
\NewDocumentCommand{\gbClsLv}{m g}{
    \renewcommand{\@gbcla}{#1}
    \IfNoValueTF{#2}{\renewcommand{\@gbclb}{}}{\renewcommand{\@gbclb}{#2}}
}

% 机关标志处理逻辑
\newcounter{issuerrows} % 机关数量
\newcounter{issueridx}  % 当前索引
\newcommand{\gbIsuOrglist}{} % 表格内容缓存

\newcommand{\gbformatissuers}[1]{
    % 1. 第一遍：计算总数
    \setcounter{issuerrows}{0}
    \renewcommand{\do}[1]{\stepcounter{issuerrows}}
    \docsvlist{#1}%

    % 2. 第二遍：构建表格行
    \renewcommand\gbIsuOrglist{}% 清空
    \setcounter{issueridx}{0}
    \renewcommand{\do}[1]{
        \stepcounter{issueridx}
        \ifnum\value{issueridx}=1
            % 第一行：使用 eqmakebox 实现分散对齐
            \gappto\gbIsuOrglist{
                \eqmakebox[gbjg][s]{##1} & \multirow{\value{issuerrows}}{*}{文件} \\
            }%
        \else
            % 后续行：使用 eqmakebox 实现分散对齐
            \gappto\gbIsuOrglist{\eqmakebox[gbjg][s]{##1} & }%
        \fi
    }
    \docsvlist{#1}
}

% 用户调用的机关命令
\newcommand{\gbIsuOrg}[1]{
    \renewcommand\@gbIsuOrg{#1}
    \gbformatissuers{#1}
}

% 签发人逻辑
\newcommand{\gbSignerlist}{} % 存储格式化后的 tabular 内容
\newcommand{\gbformatnames}[1]{% #1 逗号分隔的姓名列表
    \renewcommand\gbSignerlist{} % 重置列表
    \newcounter{signeritem}
    \setcounter{signeritem}{0}
    \renewcommand{\do}[1]{
        \stepcounter{signeritem}
        \ifnum\value{signeritem}=1
            \gappto\gbSignerlist{\kaishu ##1}% 首个姓名
        \else
            \ifodd\value{signeritem} % 奇数
                \gappto\gbSignerlist{\\\kaishu ##1}
            \else % 偶数
                \gappto\gbSignerlist{& \kaishu ##1}
            \fi
        \fi
    }
    \docsvlist{#1}% 使用 etoolbox 宏包的 \docsvlist 处理列表
}

% 用户调用的命令
\newcommand{\gbSigner}[1]{
    \renewcommand\@gbSigner{#1}
    \gbformatnames{#1}
}

% ==================================================
% 5. 版头构建 (Header Construction)
% ==================================================
% 版头
\newcommand{\makegbbantou}{
    \noindent
    \begin{minipage}[t]{0.4\textwidth}
        \heiti
        % 7.2.1 份号
        \ifx\@gbDocNo\emptyA \ \\ \else
            \eqmakebox[gbbt][s]{\@gbDocNo}\\
        \fi
        % 7.2.2 密级和保密期限
        \ifx\@gbcla\emptyA \ \else
            \eqmakebox[gbbt][s]{\@gbcla}
        \fi
        \ifx\@gbclb\emptyA \else
            \ \ding{72}\ \@gbclb
        \fi
        \\
        % 7.2.3 紧急程度
        \ifx\@gbUrgLv\emptyA \ \\ \else
            \eqmakebox[gbbt][s]{\@gbUrgLv}
        \fi
    \end{minipage}
}

% 5.1 标准公文
\newcommand{\makegbstandard}{
    \makegbbantou
    \vspace{10mm}

    % 7.2.4 发文机关标志
    \begin{center}
        \color{gbred}\zihao{-0}\xiaobiao
        \ifnum\value{issuerrows}=1 % 单机关发文: "XXX 文件"
        \@gbIsuOrg 文件
        \else
        \renewcommand{\arraystretch}{0.7}
        \begin{tabular}{@{}l@{\hspace{0.25em}}c@{}}
            \gbIsuOrglist
        \end{tabular}
        \fi
    \end{center}

    \vspace{5mm}

    \noindent
    \ifx\@gbSigner\@emptyA
        % 7.2.5 发文字号
        \begin{center}
            {\@gbDocNum}
        \end{center}
    \else
        \newsavebox\LeftContentBox
        \newsavebox\RightContentBox
        \newlength\MaxHt
        \newlength\TempHt

        % 测量左侧自然高度
        \sbox\LeftContentBox{
            {\hspace{1em} \@gbDocNum}
        }
        \setlength\MaxHt{\ht\LeftContentBox}
        \addtolength\MaxHt{\dp\LeftContentBox}

        % 测量右侧自然高度
        \sbox\RightContentBox{
            \renewcommand{\arraystretch}{0.5}
            \begin{tabular}[t]{@{}l@{\hspace{1em}}l@{}}
                \gbSignerlist
            \end{tabular}%
        }
        \setlength\TempHt{\ht\RightContentBox}
        \addtolength\TempHt{\dp\RightContentBox}
        \ifdim\TempHt > \MaxHt \setlength\MaxHt{\TempHt}\fi

        \noindent
        \begin{minipage}[b][\MaxHt][b]{0.5\textwidth}
            {\hspace{1em} \@gbDocNum}
        \end{minipage}%
        % 7.2.6 签发人
        \begin{minipage}[b][\MaxHt][t]{0.5\textwidth}
            \flushright
            \renewcommand{\arraystretch}{0.7}
            签发人：%
            \begin{tabular}[t]{@{}l@{\hspace{1em}}l@{}}
                \gbSignerlist
            \end{tabular}%
            % 居右空一字
            \hspace*{1em}
        \end{minipage}
    \fi

    % 4. 红色分隔线
    \vspace{4mm}
    {\color{gbred}\hrule height 0.7mm}

    \vspace{10mm}

    % 5. 公文标题
    \begin{center}
        {\zihao{2}\xiaobiao \@title}
    \end{center}

    \vspace{5mm}
}

% 10.1 信函格式
\newcommand{\makegbletter}{
    bypass
}

% 10.2 命令(令)格式
\newcommand{\makegbcommand}{
    bypass
}

% 10.3 纪要格式
\newcommand{\makegbnote}{
    bypass
}

% ==================================================
% 6. 成文日期与署名
% ==================================================
\newcommand{\makegbsign}[2]{
    \vspace{2cm}
    \begin{flushright}
        \begin{minipage}{0.4\textwidth}
            \centering
            {#1}\\
            {#2}
        \end{minipage}
        \hspace{2em}
    \end{flushright}
}

% ==================================================
% 7. 版记
% ==================================================
\newcommand{\makebanji}[3]{
    \vfill
    \newdimen\mylen
    \renewcommand{\arraystretch}{0}
    \hrule width\textwidth height 0.35mm
    \noindent
    \begin{tabular*}{\textwidth}{
            @{\hspace{1em}}
            p{\dimexpr\textwidth-2em\relax}
            @{\hspace{1em}}
        }
        \\[10pt]
        \zihao{4}\settowidth{\mylen}{抄送：}\hangindent=\mylen \hangafter=1
        抄送：#1。\\
        \\[10pt]
    \end{tabular*}
    \hrule width\textwidth height 0.25mm

    \noindent
    \begin{tabular*}{\textwidth}{
            @{\hspace{1em}}
            p{\dimexpr\textwidth-2em\relax}
            @{\hspace{1em}}
        }
        \\[10pt]
        \zihao{4}#2 \hfill #3印发 \\
        \\[10pt]
    \end{tabular*}
    \hrule width\textwidth height 0.35mm
}

\endinput
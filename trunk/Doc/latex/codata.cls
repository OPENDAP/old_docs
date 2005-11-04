%
% A class for generating a paper in the CODATA Data Science format
%
%  12/27/02 Tom
%
%  $Id$
%
\typeout{Codata Paper Class -- Tom Sgouros - 2003}
\NeedsTeXFormat{LaTeX2e}
\newif\if@paperdraft\@paperdraftfalse
\DeclareOption{draft}
   {\message{Using `draft' format}\input pwd.tex\@paperdrafttrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
% What follows is all a modification of the article class
\LoadClass{article}
\RequirePackage{fancyhdr}
% Select new fonts: Times Roman, Helvetica, and Computer Modern
% instead of Courier
\renewcommand{\rmdefault}{ptm}
\renewcommand{\sfdefault}{phv}
\renewcommand{\ttdefault}{cmtt}
% Make the text area on the pages longer and wider.  To adjust the
% width, the margins must also be adjusted.
\addtolength\textwidth{75pt}
\addtolength\textheight{75pt}
\addtolength\oddsidemargin{-37pt}
\addtolength\evensidemargin{-37pt}
% No indentation, leave a blank line between paragraphs.
\setlength{\parindent}{0pt}
\setlength{\parskip}{\medskipamount}
% These may be superfluous, but I wanted to be sure what point size I
% am getting.
\renewcommand\large{\@setfontsize\large\@xiipt{12}}
\renewcommand\Large{\@setfontsize\Large\@xivpt{14}}
% Title arrangement changes.
\def\title#1{\gdef\@title{\sffamily\bfseries#1}}
\def\author#1{\gdef\@author{\begin{minipage}{5.75in}
    \Large\textbf{\textit{#1}}\end{minipage}}}%
\def\date#1{\gdef\@date{\sectfont#1}}
\gdef\@date{\sectfont\today}
\newcommand\sectfont{\sffamily}
% Author footnotes should be asterisks and the like, not letters.
\def\thempfootnote{\itshape\@fnsymbol\c@mpfootnote}
% The redefinition of @maketitle and maketitle are mainly for getting
% the author footnotes up near the author names, rather than down at
% the bottom of the page.  Also font and uppercase changes.
\if@titlepage\else
\def\@maketitle{%
  \newpage
  \null
  \let\footnoterule\relax
  \let\footnotesize\normalsize
    {\noindent\Large\raggedright \MakeUppercase\@title \par}%
    \vskip 1.5em%
    {\large
      \lineskip .5em%
        \noindent\@author%
        \par}%
    \vskip 1em%
  \par%
  \vskip 1.5em}
\renewcommand\maketitle{\par
  \begingroup
    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 1em\noindent
            \hb@xt@.4em{%  This length is the indent of the footnote
                \hss\@textsuperscript{\normalfont\@thefnmark}}%
              \textit{##1}}%
    \if@twocolumn
      \ifnum \col@number=\@ne
        \@maketitle
      \else
        \twocolumn[\@maketitle]%
      \fi
    \else
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@maketitle
    \fi
    \thispagestyle{plain}\@thanks
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}
\fi
% The following are for changing the look of the section headings.
% The arguments of \@startsection are as follows:
%  1 - command name
%  2 - level (for table of contents)
%  3 - 
%  4 - vertical space before section head
%  5 - vertical space after section head
%  6 - goes right before section head itself.  Put font changes here
\renewcommand\section{\@startsection{section}{1}{\z@}%
                                   {-3.5ex \@plus -1ex \@minus -.2ex}%
                                   {2.3ex \@plus.2ex}%
                                   {\sffamily\large\bfseries%
                                     \raggedright\MakeUppercase}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
                                     {\sffamily\large\bfseries\raggedright}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
                                     {\sffamily\normalsize\bfseries\raggedright}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                    {3.25ex \@plus1ex \@minus.2ex}%
                                    {-1em}%
                                    {\sffamily\normalsize\bfseries}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
                                       {3.25ex \@plus1ex \@minus .2ex}%
                                       {-1em}%
                                      {\sffamily\normalsize\bfseries}}
% This macro is defined to make Latex section heads.  Its redefined
% here to make all the section and subsection heads line up after the
% section number.  (The addition was the "to 45pt" part.)
\def\@hangfrom#1{\setbox\@tempboxa\hbox to 45pt{{#1\hfil}}%
  \hangindent \wd\@tempboxa\noindent\box\@tempboxa}
% Change the abstract environment
\renewenvironment{abstract}{%
   \begin{center}\bgroup\sffamily\large\textbf{\textit{ABSTRACT}}\egroup\end{center}%
   \textit\bgroup\hspace{-2pt}}{\egroup}%
% Make the bibliography use \section{} instead of \section*{}.
\renewenvironment{thebibliography}[1]% 
     {\section{\refname
        \@mkboth{\MakeUppercase\refname}{\MakeUppercase\refname}}%
      \list{\@biblabel{\@arabic\c@enumiv}}%
           {\settowidth\labelwidth{\@biblabel{#1}}%
            \leftmargin\labelwidth
            \advance\leftmargin\labelsep
            \@openbib@code
            \usecounter{enumiv}%
            \let\p@enumiv\@empty
            \renewcommand\theenumiv{\@arabic\c@enumiv}}%
      \sloppy
      \clubpenalty4000
      \@clubpenalty \clubpenalty
      \widowpenalty4000%
      \sfcode`\.\@m}
     {\def\@noitemerr
       {\@latex@warning{Empty `thebibliography' environment}}%
      \endlist}
% Figure captions are to be left-justified, and to have the figure
% label in bold.
\long\def\@makecaption#1#2{%
  \vskip\abovecaptionskip
  \sbox\@tempboxa{\textbf{#1.} #2}%
  \ifdim \wd\@tempboxa >\hsize
    \textbf{#1.} #2\par
  \else
    \global \@minipagefalse
    \hb@xt@\hsize{\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}
% Page layout information
\pagestyle{fancy}
%\setlength\headheight{12pt}
\fancyhf{}
\fancyfoot[C]{}
\fancyhead[R]{\textit{Data Science Journal, Volume 2, 5 November 2003} \thepage}
\renewcommand{\headrulewidth}{0pt}
\fancypagestyle{plain}{\renewcommand{\headrulewidth}{0pt}}
%
%  $Log: codata.cls,v $
%  Revision 1.2  2003/11/05 03:46:24  tom
%  changed the date in the header.  Headers shouldn't be done this way.
%
%  Revision 1.1  2003/01/03 23:57:53  tom
%  added for DODS-doc/papers/cyb.tex
%
%
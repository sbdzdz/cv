\ProvidesClass{friggeri-cv-osx}[2012/04/30 CV class]
\NeedsTeXFormat{LaTeX2e}

\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{article}%
}
\ProcessOptions\relax
\LoadClass{article}


%%%%%%%%%%
% Colors %
%%%%%%%%%%

\RequirePackage{xcolor}

\definecolor{white}{RGB}{255,255,255}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{lightgray}{HTML}{999999}
\definecolor{darkred}{HTML}{D51644}

\colorlet{fillheader}{gray}
\colorlet{header}{white}
\colorlet{textcolor}{gray}
\colorlet{headercolor}{gray}

%%%%%%%%%
% Fonts %
%%%%%%%%%

\RequirePackage[quiet]{fontspec}
\RequirePackage{fontawesome}
\RequirePackage[math-style=TeX,vargreek-shape=unicode]{unicode-math}

\newfontfamily\bodyfont[]{Helvetica Neue Light}
\newfontfamily\thinfont[]{Helvetica Neue UltraLight}
\newfontfamily\headingfont[]{Helvetica Neue Bold}

\defaultfontfeatures{Mapping=tex-text}
\setmainfont[Mapping=tex-text, Color=textcolor]{Helvetica Neue Light}

%%%%%%%%%%
% Header %
%%%%%%%%%%

\RequirePackage{tikz}

\newcommand{\rolefont}{%
  \fontsize{14pt}{24pt}\selectfont%
  \thinfont%
  \color{white}%
}

\newcommand{\header}[3]{%
  \begin{tikzpicture}[remember picture,overlay]
    \node [rectangle, fill=fillheader, anchor=north, minimum width=\paperwidth+0.4cm, minimum height=4.4cm] (box) at ([yshift=0.1cm]current page.north){};
    \node [anchor=north west, inner sep=0pt, xshift=2.5cm, yshift=-1.0cm] (name) at (current page.north west) {%
      \fontsize{36pt}{40pt}\color{header}%
      {\headingfont #1}{\headingfont #2}
    };
    \node [anchor=north west, inner sep=0pt, xshift=2.5cm, yshift=-0.35cm, text width=16cm, align=justify] at (current page.west |- name.south) {%
      \fontsize{10pt}{13.5pt}\color{header}%
      \bodyfont\hyphenchar\font=-1\relax #3%
    };
  \end{tikzpicture}
  \vspace{1.8cm}
  %\vspace{-2\parskip}
}


%%%%%%%%%%%%%
% Structure %
%%%%%%%%%%%%%
\RequirePackage{parskip}

\def\@sectioncolor#1#2#3{%
  {%
    \color{gray} #1#2#3%
  }%
}

\renewcommand{\section}[1]{
  \par\vspace{\parskip}
  {%
    \LARGE\headingfont\color{headercolor}%
    \@sectioncolor #1%
  }
  \par\nopagebreak\vspace{\parskip}\nopagebreak
}

\renewcommand{\subsection}[1]{
  \par\vspace{.5\parskip}%
  {\Large\headingfont\color{headercolor} #1}
  \par\vspace{.25\parskip}%
}

\renewcommand{\subsubsection}[2]{
  \par\vspace{.5\parskip}%
  {\Large\headingfont\color{headercolor} #2}
  \par\vspace{.25\parskip}%
}

\pagestyle{empty}


%%%%%%%%%%%%%%%%%%%%
% List environment %
%%%%%%%%%%%%%%%%%%%%

\newlength{\entryskip}
\setlength{\entryskip}{1.2em}
\setlength{\tabcolsep}{0pt}
\newenvironment{entrylist}{%
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}ll}
}{%
  \end{tabular*}
}
\renewcommand{\bfseries}{\headingfont\color{headercolor}}
\newcommand{\entry}[4]{%
  #1&\parbox[t]{13.0cm}{%
    \textbf{#2}%
    \hfill%
    {\footnotesize\addfontfeature{Color=lightgray} #3}\\%
    #4\vspace{\parsep}%
  }\\[\entryskip]}

\newenvironment{entrylistleft}{%
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}l}
}{%
  \end{tabular*}
}
\newcommand{\entryleft}[2]{%
  \textbf{#1}\\
  #2\vspace{\parsep}\\[\entryskip]
}


%%%%%%%%%%%%%%%%
% Other tweaks %
%%%%%%%%%%%%%%%%

\RequirePackage[paper=a4paper, left=2.5cm,top=2.5cm,right=2.5cm,bottom=2.5cm,nohead,nofoot]{geometry}
\RequirePackage[hidelinks]{hyperref}
\hypersetup{
    colorlinks=false,
    linkcolor=red,
    citecolor=red,
    filecolor=red,
    urlcolor = red}

% A fix for \href{}{} colors not working with fontspec
\makeatletter
\def\HyColor@@@@UseColor#1\@nil{\addfontfeatures{Color=#1}}
\makeatother

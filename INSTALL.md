
### Install dependencies
<hr>

`Tested On Rocky Linux 8 OS`

#### 1. Basic tools

```bash
dnf update -y
dnf install epel-release -y
dnf install gcc -y
dnf install gcc-gfortran -y
yum install gcc-c++ -y
yum install readline-devel -y
yum install libX11-devel -y
yum install libXt-devel -y
dnf install tcl tcl-devel tk tk-devel  -y
dnf install xz-devel  -y
dnf install pcre2-devel -y
dnf install libcurl-devel -y
dnf install cairo-devel  -y
dnf install openssl-devel  -y
dnf install hdf5 hdf5-devel  -y
dnf install libgit2 -y
dnf install glpk-utils -y
dnf install glpk-devel   -y
```

#### 2. Perl packages

```
dnf install perl-CPAN -y
cpan App::cpanminus
cpanm  Switch 
```

#### 3. R packages

```R
install.packages("BiocManager")
install.packages("ellipse")
BiocManager::install("tidyverse")
BiocManager::install("hrbrthemes")
BiocManager::install("kableExtra")
BiocManager::install("vegan")
BiocManager::install("viridis")
BiocManager::install("docopt")
BiocManager::install("knitr")
BiocManager::install("rmarkdown")
install.packages(c("viridis","Cairo", "ellipse"))
install.packages("tidyverse")
install.packages("Rmisc")
install.packages('pheatmap')
install.packages('hrbrthemes')
install.packages('ggrepel')
install.packages('dendextend')
install.packages("devtools")
install.packages('castor')
```

#### 4. Python packages

```bash
sudo yum install --enablerepo=powertools python3-devel python3 -y
sudo alternatives --set python /usr/bin/python3
pip3 install numpy -i https://pypi.mirrors.ustc.edu.cn/simple/
pip3 install Cython -i https://pypi.mirrors.ustc.edu.cn/simple/
pip3 install pandas -i https://pypi.mirrors.ustc.edu.cn/simple/
pip3 install scipy -i https://pypi.mirrors.ustc.edu.cn/simple/
pip3 install biome-format -i https://pypi.mirrors.ustc.edu.cn/simple/
```

#### 5. Other tools

```text
hmmer
epa-ng
gappa
MinPath
pandoc
Picrust
```
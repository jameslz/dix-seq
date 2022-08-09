## Dix-seq: An integrated pipeline for fast amplicon data analysis
<hr>

### 1. Abstract

The amplicon derived from 16S rRNA genes, 18S rRNA genes, internal transcribed spacer sequences or other functional genes can be used to infer and evaluate microbial diversity or functional gene diversity. With the development of sequencing technologies, large amounts of amplicon data were generated. Several different software or pipelines had been developed for amplicon data analyses. However, most current software/pipelines require multistep and advanced programming skills. Moreover, they are often complex and time-consuming. Here, we introduced an integrated pipeline named Dix-seq for high-throughput amplicon sequence data processing. Dix-seq integrates several different amplicon analysis algorithms and software for diversity analyses of multiple samples. Dix-seq analyzes amplicon sequences efficiently, and exports abundant visual results automatically with only one command in Linux environment. In summary, Dix-seq enables the common/advanced users to generate amplicon analysis results easily and offers a versatile and convenient tool for researchers. 

### 2. Dependencies and Install

INSTALL.md

### 3. Get to start

#### 3.1 install dix-seq

```sh
git clone https://github.com/jameslz/dix-seq
```

#### 3.2 install USEARCH

```sh
wget https://drive5.com/downloads/usearch11.0.667_i86linux32.gz
gunzip usearch11.0.667_i86linux32.gz
mv usearch11.0.667_i86linux32 usearch
chmod -R 775 usearch
mv  usearch denoise-kit/binaries
```

`Recommend:` use USEARCH 64bit https://www.drive5.com/usearch/buy64bitru.html

#### 3.3 install USEARCH SINTAX db

```sh
cd dix-seq/db
wget -O PR2_4.14.zip https://zenodo.org/record/6976950/files/PR2_4.14.zip?download=1
wget -O rdp_16s_v18_sp.zip https://zenodo.org/record/6976950/files/rdp_16s_v18_sp.zip?download=1
wget -O unite_10.05.2021.zip https://zenodo.org/record/6976950/files/unite_10.05.2021.zip?download=1
unzip PR2_4.14.zip
unzip rdp_16s_v18_sp.zip
unzip unite_10.05.2021.zip
../binaries/usearch -makeudb_usearch  rdp_16s_v18_sp.fasta  -output  rdp_16s_v18_sp.udb
../binaries/usearch -makeudb_usearch  PR2_4.14.fasta  -output  PR2_4.14.udb
../binaries/usearch -makeudb_usearch  unite_10.05.2021.fasta  -output  unite_10.05.2021.udb
```

#### 3.4 run example

Go to example dir and get the template file

```sh
dix-seq metadata.txt validate
dix-seq metadata.txt pipeline
```


### 4. citation
   
```text 
Dix-seq: An integrated pipeline for fast amplicon data analysis
Yongjun wei, Tianqi Ren, Lei Zhang
bioRxiv 2020.05.11.089748; doi: https://doi.org/10.1101/2020.05.11.089748
```
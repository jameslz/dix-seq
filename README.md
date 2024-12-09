## Dix-seq: An integrated pipeline for fast amplicon data analysis
<hr>

Update: **version 1.0.0**

Notes: USEARCH (https://github.com/rcedgar/usearch12) was open sourced and donated to the public domain, So we integrated USEARCH (usearch11.0.667_i86linux64) into prebuilt APPTAINER sif image.

### 1. abstract

Rapid advancements in sequencing technologies in the past decade have driven the widespread adoption of amplicon analysis. Various software has been developed for amplicon data analysis. However, current software/pipelines often require manual intervention between multiple steps, necessitating a clear understanding of parameters and hindering inexperienced users from automating their workflows. Here, we introduce an integrated pipeline named Dix-seq for high-throughput amplicon sequence data processing. Dix-seq integrated more than 21 algorithms, software, and third-party procedures into eight modules, enabling the analysis from raw amplicon sequences to various statistical and visualization results. The pipeline achieves highlevels of automation through the use of a parameter card file, which consolidates all settings and allows users to complete the entire data analysis with a single command in one step. Furthermore, Dix-seq’s modular design and scalability enable experienced users to fine-tune the workflow to their needs, ensuring reproducible and customizable analysis. Benchmarks performed on datasets from two real-world case studies demonstrated that Dix-seq excels in extracting biologically meaningful patterns, generating publish-ready figures integrated with statistical information, and retaining/detecting variance even at low sequencing depths. In summary, Dix-seq is a fast, convenient, and versatile tool for amplicon analysis. It is tailored towards both entry-level and experienced users, providing publication-ready results with a single command while maintaining customizability and reproducibility.

### 2. build images

```sh
apptainer build --fakeroot dix-seq-1.0.0.sif  dix-seq-1.0.0.def
```

### 3. INSTALL and get start

Get prebuilt dix-seq sif file and db files from figshare.

```sh
#download sif image
wget https://figshare.com/ndownloader/files/51022509 -O dix-seq-1.0.0.sif

#download db file
wget  https://figshare.com/ndownloader/files/51060284  -O db.tar.gz
tar xzvf db.tar.gz

#download test data
wget https://figshare.com/ndownloader/files/51047609 -O test-data.tar.gz
tar xzvf test-data.tar.gz; mv test-data/* ./; rm -rf test-data

#modify metadata.txt file, setting project_home,project_id,raw_data,mapping_file and db location.

#validate metadata and fastq files.
apptainer exec dix-seq-1.0.0.sif dix-seq metadata.txt validate

#use pipeline for standand analysis.
apptainer exec dix-seq-1.0.0.sif dix-seq metadata.txt pipeline
```


### 4. misc

[Step By Step Data Analysis For Amplicon Sequencing Data](https://github.com/jameslz/dix-seq/wiki/Step-By-Step-Data-Analysis-For-Amplicon-Sequencing-Data)

[Dix-seq: 扩增子数据分析工作流使用说明](https://logictek.feishu.cn/docx/GzcbdKEs0oBF2dx4avDcaiz3n6d)

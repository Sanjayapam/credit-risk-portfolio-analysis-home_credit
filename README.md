                                                        **Credit Risk Portfolio Analysis**

**_link dashboard_**:
https://app.powerbi.com/view?r=eyJrIjoiOWViZGNhMjQtYTdkZC00MGMxLWE4NDMtODA4ZWU2NzRhMzU5IiwidCI6IjllMmViN2RhLTgyZDItNDc0Zi1iZTY2LTJlOTJiNmMwYjliYyIsImMiOjEwfQ%3D%3D

**Project Framework (CRISP-DM)
1️⃣ Business Understanding**
**Tujuan project:**
Menganalisis risiko kredit pada portofolio pinjaman konsumen untuk:
memonitor kesehatan portofolio
mengidentifikasi segmen berisiko tinggi
mendeteksi early warning signal sebelum kredit menjadi default

**Pertanyaan bisnis utama:**
Segmen nasabah mana yang memiliki default rate tertinggi?
Apakah debt ratio mempengaruhi probabilitas default?
Bagaimana distribusi risiko berdasarkan demografi dan lokasi?
Apakah terdapat indikasi over-leveraging pada debitur?

**2️⃣ Data Understanding**
Dataset berasal dari Home Credit Risk Dataset yang berisi data aplikasi pinjaman.
**Dataset utama:**
train	informasi aplikasi kredit
bureau	histori kredit eksternal
installments	histori pembayaran cicilan

**Informasi yang tersedia:**
demografi nasabah
pekerjaan
pendapatan
jumlah kredit
histori pembayaran
histori kredit eksternal

**3️⃣ Data Preparation (SQL)**

Tahapan ini dilakukan menggunakan PostgreSQL.
Langkah utama:

**Data Cleaning**
**Normalisasi variabel:**
gender
education
occupation
housing type
Contoh:
CASE 
WHEN code_gender='F' THEN 'female'
WHEN code_gender='M' THEN 'male'
END

**Feature Engineering**
Beberapa fitur risiko dibuat:
Debt Service Ratio
cicilan_setahun / income_setahun
Menunjukkan kemampuan membayar cicilan.
Total Debt Ratio
(cicilan_setahun + cicilan_lain) / income_setahun
Mengukur beban hutang total terhadap income.
Disposable Income
income - total installment
Mengukur sisa pendapatan setelah membayar cicilan.
Credit Utilization
tunggakan / plafon
Menunjukkan pemanfaatan kredit eksternal.
Payment Deficit Ratio
(installment - payment) / installment
Mengidentifikasi pola pembayaran tidak penuh.

**Data Aggregation**
Menggabungkan 3 sumber data:

Layer	Source
Demographic	train
External credit	bureau
Payment behavior	installment
Analytical Dataset

Dataset akhir dibuat sebagai SQL view untuk konsumsi BI tool.


CREATE VIEW vw_credit_risk_features AS
SELECT ...

**4️⃣ Data Modeling & Metrics**

Beberapa credit risk metrics yang dihitung:

**Metric	Deskripsi**
Default Rate	persentase debitur gagal bayar
Debt Service Ratio (DSR)	rasio cicilan terhadap income
Portfolio at Risk (PAR30/60/90)	kredit menunggak
Exposure to Income	total hutang dibanding income
Payment Deficit Ratio	indikasi stress pembayaran

**5️⃣ Data Visualization (Power BI)**
Dashboard dibuat menggunakan Microsoft Power BI.
Dashboard terdiri dari 2 halaman utama.

**Page 1 – Executive Risk Overview**
**Tujuan halaman ini:**
Memberikan ringkasan kesehatan portofolio kredit.
**KPI utama:**
Total Borrowers
Total Exposure
Default Rate
Average Debt Service Ratio
Portfolio at Risk
Visualisasi utama:
Default vs Current
Portfolio at Risk
Default rate by age group
Risk distribution by gender
Geographic risk map

**Page 2 – Demographic & Asset Profiling**
Halaman ini digunakan untuk risk segmentation.
**Analisis:**
Default rate by education
Default rate by family size
Housing type risk
Income vs debt ratio
Risk by occupation

**Tujuan:**
Mengidentifikasi segmen nasabah yang berisiko tinggi.

**6️⃣ Insights**
Debitur dengan pendidikan rendah memiliki default rate lebih tinggi
Nasabah dengan debt ratio tinggi lebih rentan gagal bayar
Segmen pekerjaan tertentu menunjukkan risiko kredit lebih tinggi
Distribusi risiko berbeda antar wilayah

**7️⃣ Business Impact**
Dashboard ini dapat digunakan oleh:
risk management team
credit analyst
internal audit
portfolio monitoring team

**Manfaat:**
monitoring kesehatan portofolio
mendeteksi early warning signal
membantu pengambilan keputusan kredit

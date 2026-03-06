with base as (
select 
sk_id_curr,
target,
case mod(sk_id_curr, 34::bigint)
            when 0 then 'aceh'::text
            when 1 then 'sumatera utara'::text
            when 2 then 'sumatera barat'::text
            when 3 then 'riau'::text
            when 4 then 'jambi'::text
            when 5 then 'sumatera selatan'::text
            when 6 then 'bengkulu'::text
            when 7 then 'lampung'::text
            when 8 then 'kepulauan bangka belitung'::text
            when 9 then 'kepulauan riau'::text
            when 10 then 'dki jakarta'::text
            when 11 then 'jawa barat'::text
            when 12 then 'jawa tengah'::text
            when 13 then 'di yogyakarta'::text
            when 14 then 'jawa timur'::text
            when 15 then 'banten'::text
            when 16 then 'bali'::text
            when 17 then 'nusa tenggara barat'::text
            when 18 then 'nusa tenggara timur'::text
            when 19 then 'kalimantan barat'::text
            when 20 then 'kalimantan tengah'::text
            when 21 then 'kalimantan selatan'::text
            when 22 then 'kalimantan timur'::text
            when 23 then 'kalimantan utara'::text
            when 24 then 'sulawesi utara'::text
            when 25 then 'sulawesi tengah'::text
            when 26 then 'sulawesi selatan'::text
            when 27 then 'sulawesi tenggara'::text
            when 28 then 'gorontalo'::text
            when 29 then 'sulawesi barat'::text
            when 30 then 'maluku'::text
            when 31 then 'maluku utara'::text
            when 32 then 'papua barat'::text
            when 33 then 'papua'::text
else null::text
end as provinsi,
initcap(name_contract_type) as jenis_aplikasi,
case
            when code_gender = 'xna'::text then 'null'::text
            when code_gender = 'f'::text then 'female'::text
            else 'male'
end as gender,
floor(abs(days_birth / 365)::double precision) as usia,
case name_education_type
            when 'lower secondary'::text then 'smp'::text
            when 'secondary'::text then 'sma'::text
            when 'secondary / secondary special'::text then 'smk'::text
            when 'incomplete higher'::text then 'd3/diploma'::text
            when 'higher education'::text then 's1'::text
            when 'academic degree'::text then 's2/s3'::text
 else initcap(name_education_type)
end as education,
initcap(coalesce(occupation_type, name_income_type)) as pekerjaan,
initcap(organization_type) as tipe_kantor,
case
 when days_employed = 365243 then 0::numeric
 else round(abs(days_employed::numeric / 365::numeric), 2)
end as lama_kerja,
case
 when flag_own_car = true then 1
 else 0
 end as asset_mobil,
round(coalesce(own_car_age, 0::numeric), 0) as usia_mobil,
 case
 when flag_own_realty = true then 1
 else 0
 end as asset_rumah,
initcap(name_housing_type) as tipe_rumah,
initcap(name_family_status) as status_keluarga,
 round(cnt_fam_members, 0) as jml_family,
cnt_children as jml_anak,
 amt_income_total as income_setahun,
 amt_credit as hutang_pokok,
amt_goods_price as ltv,
  amt_annuity as cicilan_setahun,
 ext_source_1,
 ext_source_2,
 ext_source_3
from train
), 
slik as (
select 
sk_id_curr,
sum(amt_credit_sum) as plafon_pinj_awal,
sum(amt_credit_sum_debt) as sipok_tunggakan,
sum(amt_annuity) as cicilan_lain,
count(distinct sk_id_bureau) as jml_pinjaman_aktif,
 max(credit_day_overdue) as max_dpd_external,
max(cnt_credit_prolong) as pengajuan_resktrukturasi
from bureau
 where credit_active = 'active'
group by 1
), 
installment as (
select 
sk_id_curr,
 avg(case
when days_entry_payment > days_instalment 
then days_entry_payment - days_instalment
else 0
end) as avg_dpd_internal,
 sum(amt_instalment) as total_wajib_bayar,
 sum(amt_payment) as total_yg_dibayar,
 sum(coalesce(amt_instalment, 0::numeric) - coalesce(amt_payment, 0::numeric)) as selisih_bayar
    from installments_clean
    group by 1
)
select 
    a.sk_id_curr,
    a.target,
    a.provinsi,
    a.jenis_aplikasi,
    a.gender,
    a.usia,
    a.education,
    a.pekerjaan,
    a.tipe_kantor,
    a.lama_kerja,
    a.asset_mobil,
    a.usia_mobil,
    a.asset_rumah,
    a.tipe_rumah,
    a.status_keluarga,
    a.jml_family,
    a.jml_anak,
    a.income_setahun,
    a.hutang_pokok,
    a.ltv,
    a.cicilan_setahun,
    a.ext_source_1,
    a.ext_source_2,
    a.ext_source_3,
    b.plafon_pinj_awal,
    b.sipok_tunggakan,
    b.cicilan_lain,
    b.max_dpd_external,
    c.avg_dpd_internal,
    c.selisih_bayar,
    round(coalesce(a.cicilan_setahun, 0::numeric) / nullif(a.income_setahun, 0::numeric), 2) as rasio_income_cicilan,
    round((coalesce(a.cicilan_setahun, 0::numeric) + coalesce(b.cicilan_lain, 0::numeric)) / nullif(a.income_setahun, 0::numeric), 2) as debt_ratio_total,
    round(a.income_setahun - (coalesce(a.cicilan_setahun, 0::numeric) + coalesce(b.cicilan_lain, 0::numeric)), 0) as est_disposable_income,
    round((a.hutang_pokok + coalesce(b.plafon_pinj_awal, 0::numeric)) / nullif(a.income_setahun, 0::numeric), 2) as total_exposure_times_income,
    round(coalesce(b.sipok_tunggakan, 0::numeric) / nullif(b.plafon_pinj_awal, 0::numeric), 2) as external_credit_utilization,
    round(coalesce(c.selisih_bayar, 0::numeric) / nullif(c.total_wajib_bayar, 0::numeric), 2) as payment_deficit_ratio,
    round(a.hutang_pokok / nullif(a.ltv, 0::numeric), 2) as loan_to_goods_ratio,
    case when a.lama_kerja::double precision > (a.usia - 15::double precision) then 1
    else 0
    end as is_employment_anomaly
from base a
left join slik b on a.sk_id_curr = b.sk_id_curr
left join installment c on a.sk_id_curr = c.sk_id_curr;

select * from finance.daily_subs;

create or replace temp table finance.daily_subs_clean as (
    select sub_start_ts::date as sub_start_date,
        date_trunc('week',sub_start_ts::date) as sub_start_week,
        date_trunc('month',sub_start_ts::date) as sub_start_month,
        date_trunc('quarter',sub_start_ts::date) as sub_start_quarter,
        date_trunc('year',sub_start_ts::date) as sub_start_year,
        user,
        sub,
        sub_period,
        concat(sub, ' ', sub_period) as full_sub_name,
        price as local_price,
        price_usd,
        currency,
        country_code
    from finance.daily_subs
);

select * from finance.daily_subs_clean;

create or replace temp table finance.daily_subs_clean_country as (
    select *
    from finance.daily_subs_clean
    left join finance.geo_lookup
    on lower(daily_subs_clean.country_code) = lower(geo_lookup.country_iso)
);

select * from finance.daily_subs_clean_country limit 10;

create or replace temp table finance.daily_subs_country_rates as (
    select daily_subs_clean_country.*,
        case when daily_subs_clean_country.currency = 'USD' then local_price else local_price*rate end as price_usd_calc
    from finance.daily_subs_clean_country
    left join finance.exchange_rates
        on lower(daily_subs_clean_country.currency) = lower(exchange_rates.currency)
        and daily_subs_clean_country.sub_start_month = exchange_rates.date);

select * from finance.daily_subs_country_rates;

with daily_subs_clean as (
    select sub_start_ts::date as sub_start_date,
        date_trunc('week',sub_start_ts::date) as sub_start_week,
        date_trunc('month',sub_start_ts::date) as sub_start_month,
        date_trunc('quarter',sub_start_ts::date) as sub_start_quarter,
        date_trunc('year',sub_start_ts::date) as sub_start_year,
        user,
        sub,
        sub_period,
        concat(sub, ' ', sub_period) as full_sub_name,
        price as local_price,
        price_usd,
        currency,
        country_code
    from finance.daily_subs
),

daily_subs_clean_country as (
    select *
    from finance.daily_subs_clean
    left join finance.geo_lookup
    on lower(daily_subs_clean.country_code) = lower(geo_lookup.country_iso)
),

daily_subs_country_rates as (
    select daily_subs_clean_country.*,
        case when daily_subs_clean_country.currency = 'USD' then local_price else local_price*rate end as price_usd_calc
    from finance.daily_subs_clean_country
    left join finance.exchange_rates
        on lower(daily_subs_clean_country.currency) = lower(exchange_rates.currency)
        and daily_subs_clean_country.sub_start_month = exchange_rates.date)

select * from daily_subs_country_rates;
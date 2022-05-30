-- Data Cleaning of 'Nashville Housing' dataset



create schema housing;

use housing;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile=true;

drop table if exists nashville_housing_data;

create table nashville_housing_data(
	unique_id int,
    parcel_id varchar(20),
    land_use varchar(50),
    property_address varchar(100),
    sale_date varchar(20),
    sale_price int,
    legal_reference varchar(50),
	sold_as_vacant char(3),
    owner_name varchar(75),
    owner_address varchar(100),
    acreage float,
    tax_district char(50),
    land_value int,
    building_value int,
    total_value int,
    year_built year,
    bedrooms smallint,
    full_bath smallint,
    half_bath smallint
);

update nashville_housing_data set sale_date= str_to_date(sale_date, '%m-%d-%Y');

load data local infile 'C:/Users/KIIT/Downloads/Nashville Housing Data for Data Cleaning.csv' into table nashville_housing_data
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from nashville_housing_data
order by parcel_id;


-- Fixing the date format

select sale_date, date_format(str_to_date(sale_date, '%M %d, %Y'), '%Y-%m-%d') as sale_date
from nashville_housing_data;

update nashville_housing_data set sale_date= date_format(str_to_date(sale_date, '%M %d, %Y'), '%Y-%m-%d');


-- Populating the Property Address column

select property_address from nashville_housing_data;

select a.parcel_id, a.property_address, b.parcel_id, b.property_address
from nashville_housing_data a
join 
nashville_housing_data b on a.parcel_id=b.parcel_id and a.unique_id!=b.unique_id
where a.property_address='';

UPDATE nashville_housing_data a
        JOIN
    nashville_housing_data b ON a.parcel_id = b.parcel_id
        AND a.unique_id != b.unique_id 
SET 
    a.property_address = IF(a.property_address = '',
        b.property_address,
        a.property_address)
WHERE
    a.property_address = '';


-- Spliting 'property_address' and 'owner_address'

select substring(property_address, 1, position(',' in property_address)- 1) as address
from nashville_housing_data;

select substring(property_address, 1, position(',' in property_address)- 1) as address, substring(property_address, position(',' in property_address)+ 1, length(property_address)) as city
from nashville_housing_data;

alter table nashville_housing_data
add column address varchar(100);

update nashville_housing_data set address= substring(property_address, 1, position(',' in property_address)- 1);

alter table nashville_housing_data
add column city varchar(20);

update nashville_housing_data set city= substring(property_address, position(',' in property_address)+ 1, length(property_address));


select owner_address from nashville_housing_data;

select 
	substring_index(owner_address, ',', 1),
	substring_index(substring_index(owner_address, ',', 2), ',', -1),
    substring_index(owner_address, ',', -1)
from nashville_housing_data;

alter table nashville_housing_data
add column owner_main_address varchar(100);

update nashville_housing_data set owner_main_address= substring_index(owner_address, ',', 1);

alter table nashville_housing_data
add column owner_city varchar(100);

update nashville_housing_data set owner_city= substring_index(substring_index(owner_address, ',', 2), ',', -1);

alter table nashville_housing_data
add column owner_state varchar(100);

update nashville_housing_data set owner_state= substring_index(owner_address, ',', -1);


-- Replacing "Y" and "N" with "Yes" and "No" respectively in 'sold_as_vacant'

select sold_as_vacant, count(sold_as_vacant)
from nashville_housing_data
group by sold_as_vacant
order by 2;

update nashville_housing_data set sold_as_vacant=
	case
    when sold_as_vacant='Y' then 'Yes'
    when sold_as_vacant='N' then 'No'
    else sold_as_vacant
    end;

    
-- Removing Duplicates

with dups as(
	select *, row_number() over(
    partition by
    parcel_id,
    property_address,
    sale_date,
    sale_price,
    legal_reference,
    total_value
    order by unique_id) dup
from nashville_housing_data)

delete from dups
where dup > 1;

-- select * from dups
-- where dup > 1
-- order by parcel_id;


-- Delete unnecessary columns

alter table nashville_housing_data
drop column property_address;

alter table nashville_housing_data
drop column owner_address;

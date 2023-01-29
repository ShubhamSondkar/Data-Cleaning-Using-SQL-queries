-- Cleaning Nashville Housing Dataset
select * from dbo.house

-- Standardizing Sales Date

select saledate,convert(date,saledate) from dbo.house

Alter table dbo.house 
add sale_date_conv date

select saledate,convert(date,saledate) from dbo.house

update dbo.house
set sale_date_conv = convert(date,saledate)

select sale_date_conv from dbo.house

--- Property Address Data changing NULL values

select * from dbo.house
where propertyaddress is null

select h1.parcelid,h1.propertyaddress,h2.parcelid,h2.propertyaddress,ISNULL(h1.propertyaddress,h2.propertyaddress)
from dbo.house as h1
join dbo.house h2 ON h1.parcelid = h2.parcelid
and h1.[UniqueID ] != h2.[UniqueID ]
where h1.propertyaddress is null

update h1
set propertyaddress = ISNULL(h1.propertyaddress,h2.propertyaddress)
from dbo.house as h1 JOIN dbo.house as h2 
on h1.parcelid = h2.parcelid
and h1.[UniqueID ] != h2.[UniqueID ]
WHERE h1.propertyaddress is null


--- Spearating the Address column into three columns (Address,City,State)
select PropertyAddress,Prop_address_conv,Prop_city_conv from dbo.house

select substring(propertyaddress,1,charindex(',',propertyaddress)-1) as Address1,
substring(propertyaddress,charindex(',',propertyaddress)+2,20) as city
from dbo.house

Alter table dbo.house 
ADD  Prop_address_conv nvarchar(255)

update dbo.house 
set Prop_address_conv = substring(propertyaddress,1,charindex(',',propertyaddress)-1)

Alter table dbo.house
ADD Prop_city_conv nvarchar(255)


Update dbo.house
set Prop_city_conv = substring(propertyaddress,charindex(',',propertyaddress)+2,20)



-- Breaking owner address column

select owneraddress from dbo.house

select owneraddress, parsename(replace(owneraddress,',','.'),1),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),3)
from dbo.house

alter table dbo.house
ADD Owner_address_conv nvarchar(255)

alter table house
add Owner_city_conv nvarchar(255)

Alter table house
add Owner_state_code nvarchar(255)

update dbo.house
set owner_address_conv = parsename(replace(owneraddress,',','.'),3)

Update house
set Owner_city_conv = parsename(replace(owneraddress,',','.'),2)

update house
set Owner_state_code = parsename(replace(owneraddress,',','.'),1)

select owneraddress,owner_address_conv,owner_city_conv,owner_state_code
from house



---- Changing Y = Yes and N = No for SoldasVacant column

select distinct(soldasvacant),COUNT(soldasvacant) as total from house
group by soldasvacant order by total 

select soldasvacant, 
case when soldasvacant= 'Y' Then 'Yes'  
     when soldasvacant='N' then 'No' 
	 else soldasvacant 
	 END
From house

update house
set soldasvacant = case when soldasvacant = 'Y' THEN 'Yes'
                        when soldasvacant = 'N' THEN 'No'
						ELSE soldasvacant
						END


---- REMOVING DUPLICATES
select *,
row_number() over (
                   partition by parcelid,propertyaddress,saledate,saleprice,legalreference 
                   order by uniqueid) as rw 
from house;

with cte as (
select *,
row_number() over (
                   partition by parcelid,propertyaddress,saledate,saleprice,legalreference 
                   order by uniqueid) as rw 
from house) 
Delete
from cte      
where rw > 1
-- order by PropertyAddress


----- Delete Unused columns 
select * from house

Alter table house
drop column PropertyAddress,OwnerAddress,SaleDate,TaxDistrict 
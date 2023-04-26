use portfolio;
select * from Nashville;

--standardise Date format--
select saledate
from Nashville;

alter table Nashville
add saledateconverted date;

update Nashville
set Saledateconverted=CONVERT(date,saledate);

select saledate,Saledateconverted
from Nashville;

--Populate Property adress data--
select parcelid,PropertyAddress
from Nashville
where PropertyAddress is null;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville a 
join Nashville b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null;

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville a 
join Nashville b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null;

--Breaking out propertyAddress into individual parts--

select propertyaddress
from Nashville;

select
SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress) )as City
from Nashville;

alter table Nashville
add PropertyAddressspilt nvarchar(255);

update Nashville
set PropertyAddressspilt=SUBSTRING(propertyaddress,1,charindex(',',propertyaddress)-1);
						

alter table Nashville
add PropertyCityspilt nvarchar(255);

update Nashville
set PropertyCityspilt=SUBSTRING(propertyaddress,charindex(',',propertyaddress)+1,LEN(propertyaddress) );

select propertyaddress,PropertyAddressspilt,PropertyCityspilt
from Nashville;


--Breaking out OwnerAddress into individual parts--

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from Nashville;

alter table Nashville
add ownerstatespilt nvarchar(255);

update Nashville
set ownerstatespilt=PARSENAME(replace(owneraddress,',','.'),1)

alter table Nashville
add ownerCityspilt nvarchar(255);

update Nashville
set ownerCityspilt=PARSENAME(replace(owneraddress,',','.'),2);

alter table Nashville
add owneraddressspilt nvarchar(255);

update Nashville
set owneraddressspilt=PARSENAME(replace(owneraddress,',','.'),3);

select
*
from Nashville;

--change y and N to YES and NO in 'sold as vacant ' feild--

select 
distinct(SoldAsVacant)
from Nashville;

select 
SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No' 
		else SoldAsVacant end
from Nashville;

update Nashville
set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes' 
						when SoldAsVacant = 'N' then 'No' 
						else SoldAsVacant end;

--remove duplicates--
with rownum as (
select 
*,
ROW_NUMBER() 
	over(partition by 
					parcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					Legalreference
		order by uniqueID) as row_num
from Nashville
--order by ParcelID
)

delete
from rownum
where row_num>1
;

--Delete UNUSED Columns--

alter table Nashville
Drop column owneraddress,taxdistrict,propertyaddress;
alter table Nashville
Drop column saledate;
select 
* 
from Nashville
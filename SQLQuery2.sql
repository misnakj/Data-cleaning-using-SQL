use portfolioProject

--CLEANING DATA IN SQL QUEREIES

select *
from nashville_housing;
---------------------------------------------------------------------------------------------------------------
--standardise date format
alter table nashville_housing
add SaleDateConverted date;

update nashville_housing
set SaleDateConverted=convert(date,SaleDate);

SELECT SaleDate,SaleDateConverted
FROM nashville_housing;

----------------------------------------------------------------------------------------------------

--populate property address data
select PropertyAddress
from nashville_housing;

select PropertyAddress
from nashville_housing
where PropertyAddress is null; --there is na values in address so we have to fill it with correct address.

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from nashville_housing as a
join nashville_housing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from nashville_housing as a
join nashville_housing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

---------------------------------------------------------------------------------------------------------------
--breaking out addresses into individual columns(address,city) 

--property address
select PropertyAddress
from nashville_housing;   --it has address & city

select
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address1,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from nashville_housing;          --now we separated it.

alter table nashville_housing
add propertySplitAddress nvarchar(200)

update nashville_housing
set propertySplitAddress=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

alter table nashville_housing
add PropertyCity nvarchar(200)

update nashville_housing
set PropertyCity=substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));

--Owner address
select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from nashville_housing            --separated address,city,state.

alter table nashville_housing
add OwnerSplitProperty nvarchar(100)

update  nashville_housing
set OwnerSplitProperty=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table nashville_housing
add OwnerCity nvarchar(100)

update nashville_housing
set OwnerCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table nashville_housing
add OwnerState nvarchar(100)

update nashville_housing
set OwnerState=PARSENAME(replace(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------------

--changing Y and N to yes and no in SoldAsVacant column
select distinct(SoldAsVacant),count(SoldAsVacant)
from nashville_housing
group by SoldAsVacant;   --there is Y and N instead of yes and no

update nashville_housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
                      when SoldAsVacant='N' then 'No'
					  else SoldAsVacant
					  end

-----------------------------------------------------------------------------------
--remove duplicates
with RowNumCTE as(
select *,
        row_number() over(
		partition by ParcelID,
		             PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 order by UniqueID) AS row_num
from nashville_housing)
delete
from RowNumCTE
where row_num>1

---------------------------------------------------------------------------------------------
--delete unused columns
select * 
from nashville_housing

alter table nashville_housing
drop column PropertyAddress,OwnerAddress,TaxDistrict,SaleDate

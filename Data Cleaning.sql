select *
from NashvilleHousing


--Standardize date format
ALTER TABLE NashvilleHousing
add SaleDateUpdated date
update NashvilleHousing
set SaleDateUpdated = CONVERT(date,SaleDate)
select SaleDateUpdated
from NashvilleHousing


--check Address data null or not null
select PropertyAddress
from NashvilleHousing
where PropertyAddress is null
order by ParcelID

--processing lost Address data
--1 ParcelID is representation for 1 PropertyAddress
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--fill the blank
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]

--then check again Address data is null or not null
select PropertyAddress
from NashvilleHousing
where PropertyAddress is null
order by ParcelID


--Seperate Address into address, city
select PropertyAddress
from NashvilleHousing
order by ParcelID

select PropertyAddress,
--looking from beginning string to ','
substring(PropertyAddress, 0, CHARINDEX(',',PropertyAddress)) as AddressSplited,
--looking from ',' to the end string
substring(PropertyAddress, charindex(',',PropertyAddress) +1,len(PropertyAddress)) as CitySplited
from NashvilleHousing

alter table NashvilleHousing
add AddressSplited nvarchar(255),
CitySplited nvarchar(255)

Update NashvilleHousing
set AddressSplited=substring(PropertyAddress, 0, CHARINDEX(',',PropertyAddress)),
CitySplited=substring(PropertyAddress, charindex(',',PropertyAddress) +1,len(PropertyAddress))

--check the result
select *
from NashvilleHousing


--Owneradress
select OwnerAddress
from NashvilleHousing
where OwnerAddress is null

select
parsename(replace(OwnerAddress,',','.'),3) as OwnerAddresssplited,
parsename(replace(OwnerAddress,',','.'),2) as OwnerCitySplited,
parsename(replace(OwnerAddress,',','.'),1) as OwnerStateSplited
from NashvilleHousing

alter table NashvilleHousing
add OwnerAddresssplited nvarchar(255),
OwnerCitySplited nvarchar(255),
OwnerStateSplited nvarchar(255)

update NashvilleHousing
set OwnerAddresssplited=parsename(replace(OwnerAddress,',','.'),3),
OwnerCitySplited=parsename(replace(OwnerAddress,',','.'),2),
OwnerStateSplited=parsename(replace(OwnerAddress,',','.'),1)

--check the result
select *
from NashvilleHousing


--Check Sold as vacant
select SoldAsVacant
from NashvilleHousing
where SoldAsVacant in ('Y','N')

--Fix Y,N to Yes,No
select SoldAsVacant,
case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant= case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end

select distinct(SoldAsVacant)
from NashvilleHousing


--Check neutral value and delete them
select *,
ROW_NUMBER() over(partition by ParcelID,PropertyAddress, SaleDate,SalePrice,LegalReference order by UniqueID) row_num
from NashvilleHousing

--
with RowNumCTE AS(
select *,
ROW_NUMBER() over(partition by ParcelID, 
							PropertyAddress, 
							SaleDate,SalePrice,
							LegalReference order by UniqueID) row_num
	from NashvilleHousing
)
Delete
from RowNumCTE
where row_num>1

select *
from RowNumCTE
where ROW_NUMBER>1
order by PropertyAddress

--delete unused column
alter table NashvilleHousing
drop column OwnerAddress,TaxDisTrict,PropertyAddress,SaleDate

select*
from NashvilleHousing
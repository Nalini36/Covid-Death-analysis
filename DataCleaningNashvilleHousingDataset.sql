/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [portfolioProject].[dbo].[nashvillHousing]

  --STANDARDIZE DATA FORMAT

  SELECT saledateconverted ,CONVERT(date,SaleDate) from nashvillHousing

  UPDATE nashvillHousing
  set SaleDate=CONVERT(date,SaleDate)

  alter table nashvillHousing
 add saledateconverted date

 UPDATE nashvillHousing
  set saledateconverted =CONVERT(date,SaleDate)
  -------------------------------------------------------------------------------
  ---populate property address data

  select a.ParcelID,a.PropertyAddress,b.PropertyAddress ,b.ParcelID,
  ISNULL(a.PropertyAddress,b.PropertyAddress)
  from nashvillHousing a
  join nashvillHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
  where a.PropertyAddress is null


  update a 
  set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  from nashvillHousing a
  join nashvillHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
  where a.PropertyAddress is null

  ----------------------------------------------------------------------------------------------------------
  --BREAKING OUT ADDRESS INTO INDIVISUAL COLUMNS(ADDRESS,CITY,STATE)

  select PropertyAddress from nashvillHousing

  select 
  substring(PropertyAddress,1, charindex(',',PropertyAddress)-1) as Address,
  substring(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
  from nashvillHousing ;

ALTER TABLE nashvillHousing
Add Address nvarchar(255)

update nashvillHousing
 set Address= substring(PropertyAddress,1, charindex(',',PropertyAddress)-1) 

 ALTER TABLE nashvillHousing
Add City nvarchar(255)



update nashvillHousing
 set City= substring(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))



 ------------------------------spliting the owener address

 select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
 from nashvillHousing;

 ALTER TABLE nashvillHousing
 add OwnerAdd nvarchar(255);

 update nashvillHousing
  set OwnerAdd = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


   ALTER TABLE nashvillHousing
 add OwnerCity nvarchar(255);

 update nashvillHousing
  set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


  ALTER TABLE nashvillHousing
 add OwnerState nvarchar(255);

 update nashvillHousing
  set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

  ALTER TABLE nashvillHousing ADD PropAddress nvarchar(255);
UPDATE nashvillHousing SET PropAddress = Address;

ALTER TABLE nashvillHousing DROP COLUMN Address;

 ALTER TABLE nashvillHousing ADD PropCity nvarchar(255);
UPDATE nashvillHousing SET PropCity = City;

ALTER TABLE nashvillHousing DROP COLUMN City;

select * from nashvillHousing

------------------change y and n to Yes and No in soldas vacant field 

select distinct (SoldAsVacant) ,COUNT(SoldAsVacant)
from nashvillHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,CASE 
WHEN SoldAsVacant = 'Y'THEN 'Yes'
WHEN SoldAsVacant = 'N'THEN 'No'
ELSE SoldAsVacant
END
	

from nashvillHousing


UPDATE nashvillHousing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y'THEN 'Yes'
WHEN SoldAsVacant = 'N'THEN 'No'
ELSE SoldAsVacant
END
from nashvillHousing
-------------------REMOVE DUPLICATES

WITH  RowNumCTE AS(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY parcelID,
		PropertyAddress,
		saleprice,
		saleDate,
		LegalReference
		ORDER BY 
		UniqueID

	)row_num

from nashvillHousing
)
--ORDER BY ParcelID

 SELECT  * from RowNumCTE
where row_num>1
from nashvillHousing
order by PropertyAddress;

-------------delete unused column


alter table nashvillHousing 
drop column OwnerAddress,PropertyAddress,taxDistrict,saleDate
alter table nashvillHousing 
drop column saleDate

select * from nashvillHousing
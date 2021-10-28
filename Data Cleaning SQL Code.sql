--DATA CLEANING TECHNIQUES IN SQL

SELECT *
FROM NashvilleHousing


--1. standardize date Format

SELECT SaleDateConverted, SaleDate = CONVERT(Date, SaleDate)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Alternatively

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--2. Populating property Address data

Select nash.PropertyAddress, nash.ParcelID, ville.PropertyAddress, ville.ParcelID, ISNULL(nash.PropertyAddress, ville.PropertyAddress)
From NashvilleHousing nash
JOIN NashvilleHousing ville
     ON nash.ParcelID = ville.ParcelID
	 and nash.[UniqueID ] <> ville.[UniqueID ]
where nash.PropertyAddress is null

UPDATE nash
SET PropertyAddress = ISNULL(nash.PropertyAddress, ville.PropertyAddress)
From NashvilleHousing nash
JOIN NashvilleHousing ville
     ON nash.ParcelID = ville.ParcelID
	 and nash.[UniqueID ] <> ville.[UniqueID ]
where nash.PropertyAddress is null

--3.Breaking down the address into individual columns: address, city, state

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as city
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

--Alternative(Using Parsename and owneraddress)

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 



--4. CHANGE Y AND N TO YES AND NOO IN 'SOLD AS VACANT
Select DISTINCT(SoldASVacant),COUNT(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
	  END
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant  = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
	  END


--5.Removing Duplicates
WITH RowNumCTE AS (
Select *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   saleDate,
				   LegalReference
				   ORDER BY
				     UniqueID
					 ) row_num
from NashvilleHousing 
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

--6.deleting Unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

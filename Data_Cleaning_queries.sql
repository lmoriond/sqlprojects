/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE HousingData   -- adding the col
Add SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)  --sale date: original

--
Select saleDateConverted, CONVERT(Date,SaleDate)  --select what we need
From PortfolioProject.dbo.HousingData

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.HousingData  --we can see duplicated parcelID = propertyaddress so we can populate them to complete the NULLs in PA
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)  --join the same table and if a.PA is null then take b.PA / ISNULL ( check_expression , replacement_value )  
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null    


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null   --replacement the PA col where is NULL




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress     --PA has 2 values sepparated with comma
From PortfolioProject.dbo.HousingData
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address  --we substring from "1". Length = delimited by a "," Seaching the specific value and then trim the "," (-1) because substring counts
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address --SUBSTRING(string, start, length)
From PortfolioProject.dbo.HousingData

--adding the col address
ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

--adding the col city
ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select * --lets see the new columns added
From PortfolioProject.dbo.HousingData




---SEPARATE owner address with PARSENAME (address,city and state in 1 col) EASIER! 

Select OwnerAddress
From PortfolioProject.dbo.HousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.HousingData


--now we create the new columns we need with this replacements (3 in total)
ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--lets see how it goes
Select *
From PortfolioProject.dbo.HousingData




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)  --we will replace so we dont have duplicates (Y=Yes)
From PortfolioProject.dbo.HousingData
Group by SoldAsVacant
order by 2




Select SoldAsVacant  --we first see the replacement
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.HousingData


Update HousingData  --now we finally make the replacement
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates  (if all this columns are the same, the the data is unusable)

WITH RowNumCTE AS(     --CTE works like a temp table 
Select *,                  --We use SQL PARTITION BY clause with the OVER clause so we can specify the column we need to aggregate on.
	ROW_NUMBER() OVER (       --ROW NUMBER to spot duplicates #2=dup: Numbers the output of a result set. More specifically, returns the sequential number of a row within a partition of a result set, starting at 1 for the first row in each partition.
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.HousingData
--order by ParcelID /we cant have order by in a CTE
)
Select *
From RowNumCTE
Where row_num > 1  -- "=1" if you just need the non dup
Order by PropertyAddress



Select *
From PortfolioProject.dbo.HousingData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate






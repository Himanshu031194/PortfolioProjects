/*
Data Cleaning in SQL
*/


Select * 
from PortfolioProject..NashvilleHousing


--Standardize Date Format--


Alter Table PortfolioProject..Nashvillehousing
alter column SaleDate Date;


--Populate Property Address Data--


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
Set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


--Breaking Out Address Into Seperate Columns (i.e. Address, City, State)
--First PropertyAddress (USING SUBSTRING)


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))
From PortfolioProject..NashvilleHousing

ALter Table PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1);

ALter Table PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


--Second OwnerAddress (Using PARSENAME)


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing;

ALter Table PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALter Table PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALter Table PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


--Change 'Y' and 'N' to 'Yes' and 'No' in "SoldAsVacant" Field


Select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
Order by 2;

SELECT SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END


--Remove Duplicates


with RowNumCTE as(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order By UniqueID) row_num
from PortfolioProject..NashvilleHousing
)
Select *		--Replace 'Select *' with 'Delete' to Remove Duplicates
From RowNumCTE
Where row_num > 1


--Delete Unused Columns


Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress

Select * from 
PortfolioProject..NashvilleHousing
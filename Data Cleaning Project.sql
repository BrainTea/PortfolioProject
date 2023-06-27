/* Cleaning Data in SQL Queries */

Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format --

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate, SaleDateConverted
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data -- 

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

Select HousingA.ParcelID, HousingA.PropertyAddress, HousingB.ParcelID, HousingB.PropertyAddress, ISNULL(HousingA.PropertyAddress, HousingB.PropertyAddress)
From PortfolioProject..NashvilleHousing as HousingA
Join PortfolioProject..NashvilleHousing as HousingB
	On HousingA.ParcelID = HousingB.ParcelID
	And HousingA.[UniqueID ] <> HousingB.[UniqueID ]
Where HousingA.PropertyAddress is null

Update HousingA
Set PropertyAddress = ISNULL(HousingA.PropertyAddress, HousingB.PropertyAddress)
From PortfolioProject..NashvilleHousing as HousingA
Join PortfolioProject..NashvilleHousing as HousingB
	On HousingA.ParcelID = HousingB.ParcelID
	And HousingA.[UniqueID ] <> HousingB.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) --

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing


Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field --

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates --

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

With RowNumCTE AS(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
From PortfolioProject..NashvilleHousing)
Delete
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns --

Select *
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, Taxdistrict, PropertyAddress, SaleDate

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
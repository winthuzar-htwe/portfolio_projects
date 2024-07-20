---Cleaning Data in SQL Queries

SELECT *
FROM NashvilleHousing

---Standardize Data Format

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

---Populate Property Address Data

SELECT *
FROM NashvilleHousing
---WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] = B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing A
JOIN NashvilleHousing B ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

---Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress AS Address, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

SELECT *
FROM NashvilleHousing
WHERE SaleDateConverted IS NOT NULL

ALTER TABLE NashvilleHousing
ADD PropertySplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitState = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing

---Changing Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

---Removing Duplicates

WITH RowNumber AS (SELECT *, 
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS RowNumber
FROM NashvilleHousing)

SELECT *
FROM RowNumber
WHERE RowNumber > 1
---ORDER BY PropertyAddress

---Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate







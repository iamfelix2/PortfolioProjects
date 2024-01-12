SELECT *
  FROM cleaning..nashvillehousing


  --Standardize Date Format

  SELECT SaleDate, CONVERT (Date,SaleDate)
  FROM cleaning..nashvillehousing

 --OR

  ALTER TABLE cleaning..nashvillehousing
  ADD SaleDateConverted Date

   Update cleaning..nashvillehousing
  SET SaleDateConverted = CONVERT (Date,SaleDate)


  --Populate Property Address Data
  --Looking at the trend of data, same ParcelID, OwnerName & OwnerAddress have the same PropertyAddress
  --Using ISNULL function to replace null values after using self join

  SELECT *
  FROM cleaning..nashvillehousing
  WHERE PropertyAddress is NULL

  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  From cleaning..nashvillehousing a
  JOIN cleaning..nashvillehousing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  WHERE a.PropertyAddress is NULL
  
  UPDATE a 
  SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  From cleaning..nashvillehousing a
  JOIN cleaning..nashvillehousing b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
   WHERE a.PropertyAddress is NULL



--Breaking out Address into individual columns (Address, City, State)
--CHARINDEX returns the positon number for a character we want to use as a breaking out reference

  SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as PropAddress1, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))as PropAddress2
  FROM cleaning..nashvillehousing

  ALTER TABLE Cleaning..NashvilleHousing
  ADD PropAddress1 nvarchar (255), PropAddress2 nvarchar (255)

UPDATE Cleaning..NashvilleHousing
SET PropAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1),
PropAddress2 = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) 


--Using PARSENAME & REPLACE function to separate OwnerAddress using '.'

  SELECT OwnerAddress
  FROM cleaning..nashvillehousing

  Select
  PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as OwnerAdd1,
   PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as OwnerAdd2,
    PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as OwnerAdd3
  FROM cleaning..nashvillehousing
  

  ALTER TABLE cleaning..nashvillehousing
  ADD OwnerAdd1 nvarchar (255), OwnerAdd2 nvarchar (255), OwnerAdd3 nvarchar (255)

  UPDATE cleaning..nashvillehousing
  SET OwnerAdd1 = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
   OwnerAdd2 = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
   OwnerAdd3 = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

  SELECT *
  FROM cleaning..nashvillehousing



-- Change 1 and 0 to Yes and No in 'SoldAsVacant' column

  SELECT SoldAsVacant, 
  Case 
  WHEN SoldAsVacant = '0' THEN 'No'
  ELSE 'Yes'
  END
  FROM cleaning..nashvillehousing
  WHERE SoldAsVacant is not NULL

  ALTER TABLE cleaning..nashvillehousing
  ADD SoldAsVacUpdated nvarchar (255)


  UPDATE cleaning..nashvillehousing
  SET SoldAsVacUpdated = Case 
  WHEN SoldAsVacant = '0' THEN 'No'
  ELSE 'Yes'
  END
  WHERE SoldAsVacant is not NULL

  Select DISTINCT(SoldAsVacUpdated), Count(SoldAsVacUpdated)
  From cleaning..nashvillehousing
  GROUP BY SoldAsVacUpdated



 --Delete unused columns

  ALTER TABLE cleaning..nashvillehousing
  DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, SoldAsVacant



  --Removing Duplicates

 --By using the Count and uniqueID
  Select ParcelID, PropAddress1, count(*)
  FROM cleaning..nashvillehousing
  Group by ParcelID, PropAddress1
  Having count(*) > 1

  DELETE
  From cleaning..nashvillehousing
  Where UniqueID = (
					Select MAX(UniqueID)
					FROM cleaning..nashvillehousing
					Group by ParcelID, PropAddress1
					Having count(*) > 1)


--Or by using the self join and uniqueID

Select *
From cleaning..nashvillehousing a
JOIN cleaning..nashvillehousing b
ON a.ParcelID = b.ParcelID AND a.PropAddress1 = b.PropAddress1
WHERE a.UniqueID <> b.UniqueID


DELETE 
From cleaning..nashvillehousing
where UniqueID = (Select b.UniqueID
				From cleaning..nashvillehousing a
				JOIN cleaning..nashvillehousing b
				ON a.ParcelID = b.ParcelID AND a.PropAddress1 = b.PropAddress1
				WHERE a.UniqueID < b.UniqueID)
					




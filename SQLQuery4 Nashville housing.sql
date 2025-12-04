--Cleaning data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------
--Standardize date format
SELECT SaleDate,CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)
SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing


--ALTER TABLE NashvilleHousing 
--DROP COLUMN SaleDate


-------------------------------------------------------------------------------
--Populate Property address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT nas.ParcelID,nas.PropertyAddress,nas2.ParcelID,nas2.PropertyAddress,ISNULL(nas.PropertyAddress,nas2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing nas
JOIN PortfolioProject..NashvilleHousing nas2
ON nas.ParcelID=nas2.ParcelID
AND nas.UniqueID<>nas2.UniqueID
WHERE nas.PropertyAddress is null

UPDATE nas
SET PropertyAddress=ISNULL(nas.PropertyAddress,nas2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing nas
JOIN PortfolioProject..NashvilleHousing nas2
ON nas.ParcelID=nas2.ParcelID
AND nas.UniqueID<>nas2.UniqueID
WHERE nas.PropertyAddress is null




-------------------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address,City,State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS STATE
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS



--ALTER TABLE NashvilleHousing 
--DROP COLUMN PropertyAddress


SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--ALTER TABLE NashvilleHousing 
--DROP COLUMN OwnerAddress

SELECT *
FROM PortfolioProject..NashvilleHousing



--------------------------------------------------------------------------------------
--Change Y and N TO Yes and No in "Solid as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
,CASE WHEN SoldAsVacant='Y' THEN 'Yes'
 WHEN SoldAsVacant='N' THEN 'No'
 ELSE SoldAsVacant
 END
FROM PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




------Remove Duplicates----------------------------------------------------------------------------------


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
--DELETE
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertySplitAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




-----------------------------------------------------------------------------------------
-------Deleting unused column

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
-- Cleaning Dating in SQL Queries 

Select * 
From [portfolio project ]..[NashvilleHousing  ]


-- standarize data format 

Select SaleDateConverted, CONVERT (Date, SaleDate) 
From [portfolio project ]..[NashvilleHousing  ]

Update [NashvilleHousing  ]
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date; 

Update [NashvilleHousing  ]
SET SaleDateConverted = CONVERT(Date, SaleDate) 

-- Populate property Address data 


Select * 
From [portfolio project ]..[NashvilleHousing  ] 
order by ParcelID	

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [portfolio project ]..[NashvilleHousing  ] a
JOIN [portfolio project ]..[NashvilleHousing  ] b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID]<> b.UniqueID
Where a.PropertyAddress is null 

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [portfolio project ]..[NashvilleHousing  ] a
JOIN [portfolio project ]..[NashvilleHousing  ] b
	on a.ParcelID = b.ParcelID 
	AND a.[UniqueID]<> b.UniqueID


-- Breaking out Address Into Individual Columns 

Select  PropertyAddress
From [portfolio project ]..[NashvilleHousing  ] 

Select 
Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1 ) as Address,
Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) as Address 
FROM [portfolio project ]..[NashvilleHousing  ]


ALTER TABLE  [portfolio project ]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update [portfolio project ]..NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1 ) 

ALTER TABLE [portfolio project]..NashvilleHousing
DROP COLUMN PropertySplitCity;

ALTER TABLE [portfolio project ]..NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update [portfolio project ]..NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress)) 

Select OwnerAddress 
From [portfolio project ]..NashvilleHousing 

Select  
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From [portfolio project ]..NashvilleHousing 

ALTER TABLE [portfolio project ]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

Update [portfolio project ]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE [portfolio project ]..NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

Update [portfolio project ]..NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE [portfolio project ]..NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update [portfolio project ]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


-- Change  Y and N to Yes and No In "Sold as Vacant" Field 


Select SoldAsVacant
From [portfolio project ]..[NashvilleHousing  ] 

SELECT 
	CASE 
	WHEN SoldAsVacant = 1 THEN 'Y'
	WHEN SoldAsVacant = 0 THEN 'N' 
	END AS SoldAsVacantYN 
FROM [portfolio project ].. NashvilleHousing 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant )
From [portfolio project ]..NashvilleHousing
Group by SoldAsVacant
Order by 2 



Select SoldAsVacant,
Case When SoldAsVacant = 1 THEN 'Yes'
WHEN SoldAsVacant = 0 THEN 'No'
END AS SoldAsVacant
From [portfolio project ]..NashvilleHousing

ALTER TABLE [portfolio project]..NashvilleHousing
ADD SoldAsVacantText VARCHAR(3);

Update NashvilleHousing 
SET SoldAsVacantText = Case When SoldAsVacant = 1 THEN 'Yes'
WHEN SoldAsVacant = 0 THEN 'No'
END 
From [portfolio project ]..NashvilleHousing


-- Remove Duplicates 


WITH RowNumCTE AS( 
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID 
					) row_num 
From [portfolio project ]..NashvilleHousing
)
Select* -- Used Delete function to get rid of duplicate data 
From RowNumCTE 
Where row_num> 1 
 Order By PropertyAddress 


 -- Delete Unused Columns 

 Select* 
 From [portfolio project ]..NashvilleHousing	

 ALTER TABLE [portfolio project ]..NashvilleHousing	
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE [portfolio project ]..NashvilleHousing	
 DROP COLUMN SaleDate 

 ALTER TABLE [portfolio project ]..NashvilleHousing	
 DROP COLUMN SoldAsVacant 
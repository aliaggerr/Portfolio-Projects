select * from portfolioProject.dbo.NashvillaHousing

select SaleDate,convert(date,SaleDate) from portfolioProject.dbo.NashvillaHousing

--Convert saledate colum to shortdate
alter table NashvillaHousing
add SaleDateConverted Date;
update NashvillaHousing
set SaleDateConverted=convert(date,SaleDate)
--select Saledateconverted
select SaleDateConverted from portfolioProject.dbo.NashvillaHousing

--Populate Property address if null
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress) 
from portfolioProject.dbo.NashvillaHousing as a
join portfolioProject.dbo.NashvillaHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where b.PropertyAddress is null
--update null property addrees
UPDATE a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from portfolioProject.dbo.NashvillaHousing as a
join portfolioProject.dbo.NashvillaHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null

--breaking addresses into individual columns
select PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from portfolioProject.dbo.NashvillaHousing
--add two new colums(addres,city)
alter table portfolioProject.dbo.NashvillaHousing
add PropertySplitCity nvarchar(255);
update portfolioProject.dbo.NashvillaHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

alter table portfolioProject.dbo.NashvillaHousing
add PropertySplitAddress nvarchar(255);
update portfolioProject.dbo.NashvillaHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


--split the owneraddress with parsename(ý replaces point to comma for use the parsename)
select * from portfolioProject.dbo.NashvillaHousing

select OwnerAddress,parsename(replace(OwnerAddress,',','.'),3) as state,parsename(replace(OwnerAddress,',','.'),2) as city,
parsename(replace(OwnerAddress,',','.'),1) as address
from portfolioProject.dbo.NashvillaHousing
--and add the colums
--city
alter table portfolioProject.dbo.NashvillaHousing
add OwnerSplitCity nvarchar(255);
update portfolioProject.dbo.NashvillaHousing
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)
--state
alter table portfolioProject.dbo.NashvillaHousing
add OwnerSplitState nvarchar(255);
update portfolioProject.dbo.NashvillaHousing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),3)
--address
alter table portfolioProject.dbo.NashvillaHousing
add OwnerSplitAddress nvarchar(255);
update portfolioProject.dbo.NashvillaHousing
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),1)

select * from portfolioProject.dbo.NashvillaHousing


--change Y and N to yes and no
update portfolioProject.dbo.NashvillaHousing
set SoldAsVacant=case SoldAsVacant
                 when 'Y' then 'Yes' when 'N' then 'No'
                 end where SoldAsVacant in ('Y','N')

select SoldAsVacant,count(SoldAsVacant)  from portfolioProject.dbo.NashvillaHousing
group by SoldAsVacant

--remove duplicates
with rownumCTE as  (select *,ROW_NUMBER() over(partition by
				ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
				order by UniqueID)as row_num
from portfolioProject.dbo.NashvillaHousing )
delete from rownumCTE where row_num>1

--delete unused colums

select * from portfolioProject.dbo.NashvillaHousing

alter table portfolioProject.dbo.NashvillaHousing
drop column PropertyAddress,TaxDistrict,OwnerAddress

alter table portfolioProject.dbo.NashvillaHousing
drop column SaleDate





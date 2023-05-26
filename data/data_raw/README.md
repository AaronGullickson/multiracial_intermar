The data for this project come from an extract of the American Community Survey (ACS) data from 2010-2019. We use a full decade of ACS data to increase sample size for some smaller multiracial groups. The data were extracted from the IPUMS system. 

The data set is too large to upload to GitHub, so it is instead kept on a google drive and read in to the project using the `googledrive` package. Before running the Quarto scripts, you will need to authenticate with Google Drive with the following command:

```r
googledrive::drive_auth()
```